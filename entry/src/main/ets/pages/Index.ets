import { VpnManager } from '../services/VpnManager';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  @State isConnected: boolean = false;
  @State statusText: string = 'DISCONNECTED';
  @State endpoint: string = '198.51.100.1:443';
  private vpn: VpnManager = VpnManager.getInstance();

  build() {
    Column() {
      Row() {
        Text('HMS-NET')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00E5FF')
        Blank()
        Text(this.statusText)
          .fontSize(12)
          .fontColor(this.isConnected ? '#00FF66' : '#FF3366')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#161B22')
          .borderRadius(4)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20 })

      Blank()

      Button() {
        Column() {
          Text(this.isConnected ? 'STOP' : 'START')
            .fontSize(18)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
      }
      .width(160)
      .height(160)
      .borderRadius(80)
      .backgroundColor(this.isConnected ? '#0D47A1' : '#1F242C')
      .border({ width: 2, color: this.isConnected ? '#00E5FF' : '#30363D' })
      .onClick(async () => {
        const ctx = getContext(this) as common.UIAbilityContext;
        if (!this.isConnected) {
          const ok = await this.vpn.startTunnel(ctx, this.endpoint);
          if (ok) {
            this.isConnected = true;
            this.statusText = 'CONNECTED';
          }
        } else {
          await this.vpn.stopTunnel();
          this.isConnected = false;
          this.statusText = 'DISCONNECTED';
        }
      })

      Blank()

      Column() {
        Text('SERVER ENDPOINT')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8B949E')
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)

        TextInput({ text: this.endpoint })
          .width('100%')
          .height(48)
          .fontColor('#C9D1D9')
          .backgroundColor('#0D1117')
          .border({ width: 1, color: '#30363D' })
          .borderRadius(6)
          .onChange((val: string) => {
            this.endpoint = val;
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#05070A')
  }
}
