import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { StringValue } from 'ms';
import { Repository } from 'typeorm';
import { LoginDto } from './dto/login.dto';
import { User } from './entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.username, loginDto.password);
    return this.createAuthResponse(user);
  }

  async refresh(refreshToken: string) {
    let payload: { sub: string };

    try {
      payload = await this.jwtService.verifyAsync(refreshToken, {
        secret: this.getRefreshTokenSecret(),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const user = await this.usersRepository.findOne({
      where: { id: payload.sub, is_active: true },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    return this.createAuthResponse(user);
  }

  async getProfile(userId: string) {
    const user = await this.usersRepository.findOne({
      where: { id: userId, is_active: true },
    });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.serializeUser(user);
  }

  private async validateUser(username: string, password: string) {
    const user = await this.usersRepository.findOne({
      where: { username, is_active: true },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return user;
  }

  private createAuthResponse(user: User) {
    const payload = this.buildJwtPayload(user);

    return {
      access_token: this.jwtService.sign(payload),
      refresh_token: this.jwtService.sign(payload, {
        secret: this.getRefreshTokenSecret(),
        expiresIn: this.getRefreshTokenExpiration(),
      }),
      user: this.serializeUser(user),
    };
  }

  private buildJwtPayload(user: User) {
    return {
      sub: user.id,
      username: user.username,
      role: user.role,
      full_name: user.full_name,
      branch_id: user.branch_id,
    };
  }

  private serializeUser(user: User) {
    return {
      id: user.id,
      username: user.username,
      full_name: user.full_name,
      role: user.role,
      branch_id: user.branch_id,
    };
  }

  private getRefreshTokenSecret() {
    return this.configService.get<string>(
      'JWT_REFRESH_SECRET',
      this.configService.get<string>('JWT_SECRET', 'fallback-secret'),
    );
  }

  private getRefreshTokenExpiration() {
    return this.configService.get<string>(
      'JWT_REFRESH_EXPIRATION',
      '7d',
    ) as StringValue;
  }
}
