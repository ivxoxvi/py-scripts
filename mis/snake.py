import pygame
import random
import sys

# 初始化 Pygame
pygame.init()

# 常量定义
WIDTH, HEIGHT = 600, 400
GRID_SIZE = 20
FPS = 10

# 颜色定义
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)

# 初始化窗口
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("贪吃蛇")

# 方向控制
directions = {
    pygame.K_UP: (0, -1),
    pygame.K_DOWN: (0, 1),
    pygame.K_LEFT: (-1, 0),
    pygame.K_RIGHT: (1, 0)
}

# 游戏初始化
snake = [(WIDTH//2, HEIGHT//2)]
direction = (1, 0)
food = (random.randrange(0, WIDTH, GRID_SIZE), 
        random.randrange(0, HEIGHT, GRID_SIZE))
score = 0

# 主循环
clock = pygame.time.Clock()
running = True

while running:
    # 事件处理
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key in directions:
                new_dir = directions[event.key]
                # 防止180度转向
                if (new_dir[0] != -direction[0]) or (new_dir[1] != -direction[1]):
                    direction = new_dir

    # 移动蛇
    new_head = (snake[0][0] + direction[0]*GRID_SIZE,
                snake[0][1] + direction[1]*GRID_SIZE)
    
    # 碰撞检测
    if (new_head in snake or
        new_head[0] < 0 or new_head[0] >= WIDTH or
        new_head[1] < 0 or new_head[1] >= HEIGHT):
        running = False
    
    snake.insert(0, new_head)
    
    # 吃食物逻辑
    if snake[0] == food:
        score += 1
        food = (random.randrange(0, WIDTH, GRID_SIZE),
                random.randrange(0, HEIGHT, GRID_SIZE))
        # 确保食物不在蛇身上
        while food in snake:
            food = (random.randrange(0, WIDTH, GRID_SIZE),
                    random.randrange(0, HEIGHT, GRID_SIZE))
    else:
        snake.pop()

    # 绘制界面
    screen.fill(BLACK)
    
    # 绘制食物
    pygame.draw.rect(screen, RED, (*food, GRID_SIZE-1, GRID_SIZE-1))
    
    # 绘制蛇
    for segment in snake:
        pygame.draw.rect(screen, GREEN, (*segment, GRID_SIZE-1, GRID_SIZE-1))
    
    # 显示分数
    font = pygame.font.SysFont(None, 30)
    text = font.render(f"Score: {score}", True, WHITE)
    screen.blit(text, (10, 10))
    
    pygame.display.flip()
    clock.tick(FPS)

# 游戏结束
pygame.quit()
sys.exit()