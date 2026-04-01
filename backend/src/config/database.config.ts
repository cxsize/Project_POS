import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const getDatabaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get('DB_HOST', 'localhost'),
  port: configService.get<number>('DB_PORT', 5432),
  username: configService.get('DB_USERNAME', 'pos_user'),
  password: configService.get('DB_PASSWORD', 'pos_password'),
  database: configService.get('DB_DATABASE', 'pos_db'),
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  synchronize: configService.get('DB_SYNC', 'false') === 'true',
  logging: configService.get('DB_LOGGING', 'false') === 'true',
});
