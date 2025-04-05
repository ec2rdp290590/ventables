import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ventables/core/presentation/widgets/app_drawer.dart';
import 'package:ventables/core/presentation/widgets/error_message.dart';
import 'package:ventables/core/presentation/widgets/loading_indicator.dart';
import 'package:ventables/features/home/presentation/widgets/category_slider.dart';
import 'package:ventables/features/home/presentation/widgets/featured_products.dart';
import 'package:ventables/features/home/presentation/widgets/home_banner.dart';
import 'package:ventables/features/home/presentation/widgets/new_arrivals.dart';
import 'package:ventables/features/home/presentation/widgets/search_bar.dart';
import 'package:ventables/features/products/presentation/bloc/products_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar la página
    BlocProvider.of<ProductsBloc>(context).add(GetProductsEvent());
    
    // Configurar listener para detectar scroll y cambiar la apariencia del AppBar
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con efecto de transparencia al hacer scroll
      appBar: AppBar(
        elevation: _isScrolled ? 4 : 0,
        backgroundColor: _isScrolled 
            ? Theme.of(context).colorScheme.surface 
            : Colors.transparent,
        title: Text(
          'VenTables',
          style: TextStyle(
            color: _isScrolled 
                ? Theme.of(context).colorScheme.onSurface 
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      // Implementamos un RefreshIndicator para permitir al usuario actualizar los productos
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<ProductsBloc>(context).add(GetProductsEvent());
        },
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return LoadingIndicator();
            } else if (state is ProductsLoaded) {
              return CustomScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                slivers: [
                  // Banner principal con ofertas destacadas
                  SliverToBoxAdapter(
                    child: HomeBanner(),
                  ),
                  // Slider de categorías
                  SliverToBoxAdapter(
                    child: CategorySlider(categories: state.categories),
                  ),
                  // Productos destacados
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Productos Destacados',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FeaturedProducts(products: state.featuredProducts),
                  ),
                  // Nuevos productos
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Recién Llegados',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: NewArrivals(products: state.newProducts),
                  ),
                  // Espacio adicional al final
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              );
            } else if (state is ProductsError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  BlocProvider.of<ProductsBloc>(context).add(GetProductsEvent());
                },
              );
            }
            return LoadingIndicator();
          },
        ),
      ),
      // Botón flotante para añadir un nuevo producto (solo para vendedores)
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated && state.user.tipoUsuario == 'vendedor') {
            return FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
              child: Icon(Icons.add),
              tooltip: 'Añadir Producto',
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

// Delegado de búsqueda personalizado
class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implementar la búsqueda real de productos
    BlocProvider.of<ProductsBloc>(context).add(SearchProductsEvent(query: query));
    
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return LoadingIndicator();
        } else if (state is ProductsLoaded) {
          return ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final product = state.searchResults[index];
              return ListTile(
                leading: product.imagenes.isNotEmpty
                    ? Image.network(
                        product.imagenes[0],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.image_not_supported),
                title: Text(product.nombre),
                subtitle: Text('\$${product.precio.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: product.productoId,
                  );
                },
              );
            },
          );
        } else if (state is ProductsError) {
          return ErrorMessage(
            message: state.message,
            onRetry: () {
              BlocProvider.of<ProductsBloc>(context).add(SearchProductsEvent(query: query));
            },
          );
        }
        return LoadingIndicator();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implementar sugerencias de búsqueda
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.history),
          title: Text('Electrónicos'),
          onTap: () {
            query = 'Electrónicos';
            showResults(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.history),
          title: Text('Muebles'),
          onTap: () {
            query = 'Muebles';
            showResults(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.history),
          title: Text('Ropa'),
          onTap: () {
            query = 'Ropa';
            showResults(context);
          },
        ),
      ],
    );
  }
}
