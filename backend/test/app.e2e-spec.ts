import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

describe('App (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );
    await app.init();
  });

  it('/api/v1/auth/login (POST) - should reject invalid credentials', () => {
    return request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ username: 'wrong', password: 'wrong' })
      .expect(401);
  });

  it('/api/v1/auth/login (POST) - should return token for valid credentials', () => {
    return request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ username: 'admin', password: 'admin' })
      .expect(201)
      .expect(
        (res: {
          body: {
            access_token: string;
            refresh_token: string;
            user: { username: string };
          };
        }) => {
          expect(res.body.access_token).toBeDefined();
          expect(res.body.refresh_token).toBeDefined();
          expect(res.body.user.username).toBe('admin');
        },
      );
  });

  it('/api/v1/auth/refresh (POST) - should issue a new auth payload', async () => {
    const loginResponse = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ username: 'admin', password: 'admin' })
      .expect(201);

    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refresh_token: loginResponse.body.refresh_token })
      .expect(201)
      .expect(
        (res: {
          body: {
            access_token: string;
            refresh_token: string;
            user: { username: string };
          };
        }) => {
          expect(res.body.access_token).toBeDefined();
          expect(res.body.refresh_token).toBeDefined();
          expect(res.body.user.username).toBe('admin');
        },
      );
  });

  it('/api/v1/auth/me (GET) - should return current user profile', async () => {
    const loginResponse = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ username: 'admin', password: 'admin' })
      .expect(201);

    await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${loginResponse.body.access_token}`)
      .expect(200)
      .expect(
        (res: {
          body: { username: string; role: string; full_name: string };
        }) => {
          expect(res.body.username).toBe('admin');
          expect(res.body.role).toBeDefined();
          expect(res.body.full_name).toBeDefined();
        },
      );
  });

  afterEach(async () => {
    await app.close();
  });
});
