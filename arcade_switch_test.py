import pygame
import serial


PORT = "COM7"
BAUD_RATE = 9600


def main():
    pygame.display.init()
    pygame.font.init()

    try:
        screen = pygame.display.set_mode((640, 360))
        pygame.display.set_caption("FPGA Arcade Switch Test")
        clock = pygame.time.Clock()
        font = pygame.font.Font(None, 54)
        labels = {
            None: "Waiting for SW0...",
            0: "Arcade Menu",
            1: "Game 1",
        }
        state = None

        with serial.Serial(PORT, BAUD_RATE, timeout=0) as fpga:
            while True:
                for event in pygame.event.get():
                    if event.type == pygame.QUIT:
                        return
                    if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                        return

                # Read the bytes already available and keep the latest switch state.
                for value in fpga.read(fpga.in_waiting):
                    if value in (0, 1):
                        state = value

                screen.fill((18, 23, 35))
                label = font.render(labels[state], True, (240, 244, 255))
                screen.blit(label, label.get_rect(center=screen.get_rect().center))
                pygame.display.flip()
                clock.tick(60)
    finally:
        pygame.quit()


if __name__ == "__main__":
    main()
