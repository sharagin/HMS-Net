import vpn from '@ohos.net.vpn';
import common from '@ohos.app.ability.common';
import hmsBridge from 'libhms_bridge.so';

export class VpnManager {
  private static instance: VpnManager;
  private vpnConn: vpn.VpnConnection | null = null;
  public isRunning: boolean = false;

  public static getInstance(): VpnManager {
    if (!VpnManager.instance) {
      VpnManager.instance = new VpnManager();
    }
    return VpnManager.instance;
  }

  async startTunnel(context: common.UIAbilityContext, remoteEndpoint: string): Promise<boolean> {
    try {
      this.vpnConn = vpn.createVpnConnection(context);

      const config: vpn.VpnConfig = {
        addresses: [{
          address: { address: '172.19.0.1', family: 1 },
          prefixLength: 24
        }],
        routes: [{
          interface: 'tun0',
          destination: { address: '0.0.0.0', family: 1 },
          prefixLength: 0
        }],
        mtu: 1500,
        blocking: true
      };

      await this.vpnConn.setUp(config);
      const fd = await this.vpnConn.getFd();

      const status = hmsBridge.startCore(fd, remoteEndpoint);
      this.isRunning = (status === 0);
      return this.isRunning;
    } catch (e) {
      return false;
    }
  }

  async stopTunnel(): Promise<void> {
    if (this.vpnConn) {
      hmsBridge.stopCore();
      await this.vpnConn.destroy();
      this.vpnConn = null;
      this.isRunning = false;
    }
  }
}
