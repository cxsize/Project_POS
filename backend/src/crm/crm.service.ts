import { Injectable } from '@nestjs/common';
import { EarnPointsDto } from './dto/earn-points.dto';

@Injectable()
export class CrmService {
  findMemberByPhone(phone: string) {
    // TODO: Integrate with external CRM system
    return {
      phone,
      name: 'Stub Member',
      points: 0,
      message: 'CRM integration pending',
    };
  }

  earnPoints(dto: EarnPointsDto) {
    // TODO: Integrate with external CRM system
    return {
      order_id: dto.order_id,
      customer_id: dto.customer_id,
      points_earned: Math.floor(dto.amount / 10),
      message: 'CRM integration pending',
    };
  }
}
