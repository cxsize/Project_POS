import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { CreateIngredientDto } from './dto/create-ingredient.dto';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { Ingredient } from './entities/ingredient.entity';
import { Recipe } from './entities/recipe.entity';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(Ingredient)
    private ingredientsRepository: Repository<Ingredient>,
    @InjectRepository(Recipe)
    private recipesRepository: Repository<Recipe>,
  ) {}

  createIngredient(dto: CreateIngredientDto) {
    const ingredient = this.ingredientsRepository.create(dto);
    return this.ingredientsRepository.save(ingredient);
  }

  findAllIngredients() {
    return this.ingredientsRepository.find();
  }

  async findOneIngredient(id: string) {
    const ingredient = await this.ingredientsRepository.findOne({
      where: { id },
    });
    if (!ingredient) throw new NotFoundException(`Ingredient ${id} not found`);
    return ingredient;
  }

  findLowStock() {
    return this.ingredientsRepository
      .createQueryBuilder('i')
      .where('i.stock_qty <= i.min_alert_qty')
      .getMany();
  }

  createRecipe(dto: CreateRecipeDto) {
    const recipe = this.recipesRepository.create(dto);
    return this.recipesRepository.save(recipe);
  }

  findRecipesByProduct(productId: string) {
    return this.recipesRepository.find({
      where: { product_id: productId },
      relations: ['ingredient'],
    });
  }

  async deductStock(productId: string, qty: number, manager?: EntityManager) {
    const recipesRepository = this.getRecipesRepository(manager);
    const ingredientsRepository = this.getIngredientsRepository(manager);
    const recipes = await recipesRepository.find({
      where: { product_id: productId },
      relations: ['ingredient'],
    });

    for (const recipe of recipes) {
      const deduction = recipe.usage_qty * qty;
      const result = await ingredientsRepository
        .createQueryBuilder()
        .update(Ingredient)
        .set({ stock_qty: () => 'stock_qty - :deduction' })
        .where('id = :id', { id: recipe.ingredient_id })
        .andWhere('stock_qty >= :deduction')
        .setParameters({ deduction })
        .execute();

      if ((result.affected ?? 0) === 0) {
        throw new BadRequestException(
          `Insufficient stock for ingredient ${recipe.ingredient_id}`,
        );
      }
    }
  }

  async restoreStock(productId: string, qty: number, manager?: EntityManager) {
    const recipesRepository = this.getRecipesRepository(manager);
    const ingredientsRepository = this.getIngredientsRepository(manager);
    const recipes = await recipesRepository.find({
      where: { product_id: productId },
      relations: ['ingredient'],
    });

    for (const recipe of recipes) {
      const increment = recipe.usage_qty * qty;
      await ingredientsRepository
        .createQueryBuilder()
        .update(Ingredient)
        .set({ stock_qty: () => 'stock_qty + :increment' })
        .where('id = :id', { id: recipe.ingredient_id })
        .setParameters({ increment })
        .execute();
    }
  }

  private getIngredientsRepository(manager?: EntityManager) {
    return manager?.getRepository(Ingredient) ?? this.ingredientsRepository;
  }

  private getRecipesRepository(manager?: EntityManager) {
    return manager?.getRepository(Recipe) ?? this.recipesRepository;
  }
}
