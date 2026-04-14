import { NotFoundException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Category } from './entities/category.entity';
import { Product } from './entities/product.entity';
import { ProductsService } from './products.service';

type RepoMock<T extends object> = {
  [K in keyof Partial<Repository<T>>]: jest.Mock;
};

describe('ProductsService', () => {
  let service: ProductsService;
  let productsRepository: RepoMock<Product>;
  let categoriesRepository: RepoMock<Category>;

  beforeEach(() => {
    productsRepository = {
      create: jest.fn(),
      save: jest.fn(),
      find: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };
    categoriesRepository = {
      create: jest.fn(),
      save: jest.fn(),
      find: jest.fn(),
    };

    service = new ProductsService(
      productsRepository as unknown as Repository<Product>,
      categoriesRepository as unknown as Repository<Category>,
    );
  });

  it('creates and saves a product', async () => {
    const dto = { sku: 'SKU-1', name: 'Latte', base_price: 95 };
    const product = { id: 'product-1', ...dto };
    productsRepository.create.mockReturnValue(product);
    productsRepository.save.mockResolvedValue(product);

    await expect(service.create(dto as any)).resolves.toEqual(product);
    expect(productsRepository.create).toHaveBeenCalledWith(dto);
    expect(productsRepository.save).toHaveBeenCalledWith(product);
  });

  it('returns only active products with categories in findAll', async () => {
    productsRepository.find.mockResolvedValue([]);

    await service.findAll();

    expect(productsRepository.find).toHaveBeenCalledWith({
      where: { is_active: true },
      relations: ['category'],
    });
  });

  it('throws when findOne cannot locate a product', async () => {
    productsRepository.findOne.mockResolvedValue(null);

    await expect(service.findOne('missing-product')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('updates an existing product and returns the refreshed entity', async () => {
    const current = { id: 'product-1', name: 'Latte' };
    const updated = { id: 'product-1', name: 'Iced Latte' };
    productsRepository.findOne
      .mockResolvedValueOnce(current)
      .mockResolvedValueOnce(updated);
    productsRepository.update.mockResolvedValue(undefined);

    await expect(
      service.update('product-1', { name: 'Iced Latte' } as any),
    ).resolves.toEqual(updated);
    expect(productsRepository.update).toHaveBeenCalledWith('product-1', {
      name: 'Iced Latte',
    });
  });

  it('deletes an existing product', async () => {
    productsRepository.findOne.mockResolvedValue({ id: 'product-1' });
    productsRepository.delete.mockResolvedValue(undefined);

    await expect(service.remove('product-1')).resolves.toBeUndefined();
    expect(productsRepository.delete).toHaveBeenCalledWith('product-1');
  });

  it('creates and lists categories', async () => {
    const dto = { name: 'Coffee' };
    const category = { id: 'category-1', ...dto };
    categoriesRepository.create.mockReturnValue(category);
    categoriesRepository.save.mockResolvedValue(category);
    categoriesRepository.find.mockResolvedValue([category]);

    await expect(service.createCategory(dto as any)).resolves.toEqual(category);
    await expect(service.findAllCategories()).resolves.toEqual([category]);
  });
});
