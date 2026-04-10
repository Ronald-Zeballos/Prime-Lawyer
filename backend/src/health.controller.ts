import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  getHealth(): { status: string; app: string; timestamp: string } {
    return {
      status: 'ok',
      app: 'prime-lawyer-backend',
      timestamp: new Date().toISOString(),
    };
  }
}
