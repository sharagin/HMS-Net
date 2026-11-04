package main

/*
#include <stdint.h>
#include <stdlib.h>
*/
import "C"
import (
	"context"
	"net"
	"os"
	"sync"
	"syscall"
)

var (
	ctx    context.Context
	cancel context.CancelFunc
	mu     sync.Mutex
)

//export StartEngine
func StartEngine(fd C.int, targetAddr *C.char) C.int {
	mu.Lock()
	defer mu.Unlock()

	if cancel != nil {
		return -1
	}

	ctx, cancel = context.WithCancel(context.Background())
	tunFd := uintptr(fd)
	tunFile := os.NewFile(tunFd, "tun0")
	if tunFile == nil {
		return -2
	}

	remoteAddr := C.GoString(targetAddr)
	go processTunTraffic(ctx, tunFile, remoteAddr)

	return 0
}

//export StopEngine
func StopEngine() C.int {
	mu.Lock()
	defer mu.Unlock()

	if cancel != nil {
		cancel()
		cancel = nil
	}
	return 0
}

func processTunTraffic(ctx context.Context, tun *os.File, remote string) {
	defer tun.Close()

	rAddr, err := net.ResolveUDPAddr("udp", remote)
	if err != nil {
		return
	}

	socketFd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_DGRAM, syscall.IPPROTO_UDP)
	if err != nil {
		return
	}
	defer syscall.Close(socketFd)

	buf := make([]byte, 65535)

	for {
		select {
		case <-ctx.Done():
			return
		default:
			n, err := tun.Read(buf)
			if err != nil || n <= 0 {
				continue
			}

			var sa syscall.SockaddrInet4
			copy(sa.Addr[:], rAddr.IP.To4())
			sa.Port = rAddr.Port

			_ = syscall.Sendto(socketFd, buf[:n], 0, &sa)
		}
	}
}

func main() {}
