import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(private jwtService: JwtService) {}

  login(loginDto: LoginDto) {
    // TODO: Replace with real user validation against database
    if (loginDto.username === 'admin' && loginDto.password === 'admin') {
      const payload = {
        sub: 'admin-uuid',
        username: loginDto.username,
        role: 'admin',
      };
      return { access_token: this.jwtService.sign(payload) };
    }
    throw new UnauthorizedException('Invalid credentials');
  }
}
