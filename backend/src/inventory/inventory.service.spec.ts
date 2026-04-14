import { BadRequestException, NotFoundException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Ingredient } from './entities/ingredient.entity';
import { Recipe } from './entities/recipe.entity';
import { InventoryService } from './inventory.service';

type RepoMock<T extends object> = {
  [K in keyof Partial<Repository<T>>]: jest.Mock;
};

describe('InventoryService', () => {
  let service: InventoryService;
  let ingredientsRepository: RepoMock<Ingredient>;
  let recipesRepository: RepoMock<Recipe>;

  beforeEach(() => {
    ingredientsRepository = {
      create: jest.fn(),
      save: jest.fn(),
      find: jest.fn(),
      findOne: jest.fn(),
      createQueryBuilder: jest.fn(),
    };
    recipesRepository = {
      create: jest.fn(),
      save: jest.fn(),
      find: jest.fn(),
    };

    service = new InventoryService(
      ingredientsRepository as unknown as Repository<Ingredient>,
      recipesRepository as unknown as Repository<Recipe>,
    );
  });

  it('creates and lists ingredients', async () => {
    const dto = {
      name: 'Milk',
      unit: 'ml',
      stock_qty: 1000,
      min_alert_qty: 200,
    };
    const ingredient = { id: 'ingredient-1', ...dto };
    ingredientsRepository.create.mockReturnValue(ingredient);
    ingredientsRepository.save.mockResolvedValue(ingredient);
    ingredientsRepository.find.mockResolvedValue([ingredient]);

    await expect(service.createIngredient(dto as never)).resolves.toEqual(
      ingredient,
    );
    await expect(service.findAllIngredients()).resolves.toEqual([ingredient]);
  });

  it('throws when an ingredient cannot be found', async () => {
    ingredientsRepository.findOne.mockResolvedValue(null);

    await expect(
      service.findOneIngredient('missing-ingredient'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('finds low-stock ingredients through the query builder', async () => {
    const queryBuilder = {
      where: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue([{ id: 'ingredient-1' }]),
    };
    ingredientsRepository.createQueryBuilder.mockReturnValue(queryBuilder);

    await expect(service.findLowStock()).resolves.toEqual([
      { id: 'ingredient-1' },
    ]);
    expect(ingredientsRepository.createQueryBuilder).toHaveBeenCalledWith('i');
    expect(queryBuilder.where).toHaveBeenCalledWith(
      'i.stock_qty <= i.min_alert_qty',
    );
  });

  it('creates recipes and queries them by product', async () => {
    const dto = {
      product_id: 'product-1',
      ingredient_id: 'ingredient-1',
      usage_qty: 0.25,
    };
    const recipe = { id: 'recipe-1', ...dto };
    recipesRepository.create.mockReturnValue(recipe);
    recipesRepository.save.mockResolvedValue(recipe);
    recipesRepository.find.mockResolvedValue([recipe]);

    await expect(service.createRecipe(dto as never)).resolves.toEqual(recipe);
    await expect(service.findRecipesByProduct('product-1')).resolves.toEqual([
      recipe,
    ]);
    expect(recipesRepository.find).toHaveBeenCalledWith({
      where: { product_id: 'product-1' },
      relations: ['ingredient'],
    });
  });

  it('deducts ingredient stock with a non-negative guard', async () => {
    const execute = jest.fn().mockResolvedValue({ affected: 1 });
    const setParameters = jest.fn().mockReturnValue({ execute });
    const andWhere = jest.fn().mockReturnValue({ setParameters });
    const where = jest.fn().mockReturnValue({ andWhere });
    const set = jest.fn().mockReturnValue({ where });
    const update = jest.fn().mockReturnValue({ set });
    ingredientsRepository.createQueryBuilder.mockReturnValue({ update });

    recipesRepository.find.mockResolvedValue([
      { ingredient_id: 'ingredient-1', usage_qty: 0.5 },
      { ingredient_id: 'ingredient-2', usage_qty: 1.25 },
    ]);

    await service.deductStock('product-1', 4);

    expect(update).toHaveBeenCalledTimes(2);
    const firstSetArg = set.mock.calls[0][0] as { stock_qty: () => string };
    const secondSetArg = set.mock.calls[1][0] as { stock_qty: () => string };
    expect(firstSetArg.stock_qty()).toBe('stock_qty - :deduction');
    expect(secondSetArg.stock_qty()).toBe('stock_qty - :deduction');
    expect(where).toHaveBeenNthCalledWith(1, 'id = :id', {
      id: 'ingredient-1',
    });
    expect(where).toHaveBeenNthCalledWith(2, 'id = :id', {
      id: 'ingredient-2',
    });
    expect(andWhere).toHaveBeenCalledWith('stock_qty >= :deduction');
    expect(setParameters).toHaveBeenNthCalledWith(1, { deduction: 2 });
    expect(setParameters).toHaveBeenNthCalledWith(2, { deduction: 5 });
    expect(execute).toHaveBeenCalledTimes(2);
  });

  it('throws when stock deduction would go negative', async () => {
    const execute = jest.fn().mockResolvedValue({ affected: 0 });
    const setParameters = jest.fn().mockReturnValue({ execute });
    const andWhere = jest.fn().mockReturnValue({ setParameters });
    const where = jest.fn().mockReturnValue({ andWhere });
    const set = jest.fn().mockReturnValue({ where });
    const update = jest.fn().mockReturnValue({ set });
    ingredientsRepository.createQueryBuilder.mockReturnValue({ update });
    recipesRepository.find.mockResolvedValue([
      { ingredient_id: 'ingredient-1', usage_qty: 0.5 },
    ]);

    await expect(service.deductStock('product-1', 4)).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });
});
