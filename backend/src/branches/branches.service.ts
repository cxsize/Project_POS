import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { QueryFailedError, Repository } from 'typeorm';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { Branch } from './entities/branch.entity';

@Injectable()
export class BranchesService {
  constructor(
    @InjectRepository(Branch)
    private readonly branchesRepository: Repository<Branch>,
  ) {}

  create(dto: CreateBranchDto) {
    const branch = this.branchesRepository.create({
      name: dto.name.trim(),
      address: dto.address?.trim() || null,
    });
    return this.branchesRepository.save(branch);
  }

  findAll() {
    return this.branchesRepository.find({
      order: { created_at: 'ASC' },
    });
  }

  async findOne(id: string) {
    const branch = await this.branchesRepository.findOne({ where: { id } });
    if (!branch) {
      throw new NotFoundException(`Branch ${id} not found`);
    }
    return branch;
  }

  async update(id: string, dto: UpdateBranchDto) {
    await this.findOne(id);
    await this.branchesRepository.update(id, {
      ...(dto.name != null ? { name: dto.name.trim() } : {}),
      ...(dto.address != null ? { address: dto.address.trim() || null } : {}),
    });
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.findOne(id);
    try {
      await this.branchesRepository.delete(id);
    } catch (error) {
      if (error instanceof QueryFailedError) {
        throw new BadRequestException(
          'Cannot delete branch that is used by users or orders',
        );
      }
      throw error;
    }
  }
}
