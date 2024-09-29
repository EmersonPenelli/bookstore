#1 declarou os modelos no admin.py de cada aplicativo
#2 dentro __init__.py nós declaramos os modelos
#3 declaramos os nossos apps (product e order) dentro do bookstore project (settings.py)
#4 deletar o models.py porque nós já criamos um diretório

import factory
from django.contrib.auth.models import User

from order.models import Order
from product.factories import ProductFactory

class UserFactory(factory.django.DjangoModelFactory):
  email = factory.Faker('pystr')
  username = factory.Faker('pystr')

  class Meta:
    model = User

class OrderFactory(factory.django.DjangoModelFactory):
  user = factory.SubFactory(UserFactory)

  @factory.post_generation
  def product(self, create, extracted, **kwargs):
    if not create:
      return

    if extracted:
      for product in extracted:
        self.product.add(product)

  class Meta:
    model = Order
