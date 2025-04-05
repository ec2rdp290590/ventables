import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ventables/core/presentation/widgets/error_message.dart';
import 'package:ventables/core/presentation/widgets/loading_indicator.dart';
import 'package:ventables/core/presentation/widgets/product_card.dart';
import 'package:ventables/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ventables/features/recommendations/presentation/bloc/recommendations_bloc.dart';

class RecommendationsPage extends StatefulWidget {
@override
_RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> with SingleTickerProviderStateMixin {
late TabController _tabController;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  
  // Cargar recomendaciones
  _loadRecommendations();
}

void _loadRecommendations() {
  final authState = BlocProvider.of<AuthBloc>(context).state;
  if (authState is Authenticated) {
    BlocProvider.of<RecommendationsBloc>(context).add(
      GetPersonalizedRecommendationsEvent(userId: authState.user.usuarioId),
    );
  }
  
  BlocProvider.of<RecommendationsBloc>(context).add(GetTrendingProductsEvent());
}

@override
void dispose() {
  _tabController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Recomendaciones'),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Para Ti'),
          Tab(text: 'Tendencias'),
          Tab(text: 'Descubrimientos'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Pestaña "Para Ti"
        BlocBuilder<RecommendationsBloc, RecommendationsState>(
          builder: (context, state) {
            if (state is PersonalizedRecommendationsLoading) {
              return LoadingIndicator();
            } else if (state is PersonalizedRecommendationsLoaded) {
              final recommendations = state.recommendations;
              
              if (recommendations.isEmpty) {
                return _buildEmptyState(
                  'No hay recomendaciones personalizadas disponibles',
                  'Explora más productos para obtener recomendaciones personalizadas',
                  Icons.recommend,
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  _loadRecommendations();
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: recommendations[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product-details',
                          arguments: recommendations[index].productoId,
                        );
                      },
                    );
                  },
                ),
              );
            } else if (state is RecommendationsError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  _loadRecommendations();
                },
              );
            }
            
            return LoadingIndicator();
          },
        ),
        
        // Pestaña "Tendencias"
        BlocBuilder<RecommendationsBloc, RecommendationsState>(
          builder: (context, state) {
            if (state is TrendingProductsLoading) {
              return LoadingIndicator();
            } else if (state is TrendingProductsLoaded) {
              final trendingProducts = state.trendingProducts;
              
              if (trendingProducts.isEmpty) {
                return _buildEmptyState(
                  'No hay productos en tendencia disponibles',
                  'Vuelve más tarde para ver los productos más populares',
                  Icons.trending_up,
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<RecommendationsBloc>(context).add(GetTrendingProductsEvent());
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: trendingProducts.length,
                  itemBuilder: (context, index) {
                    final product = trendingProducts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product-details',
                            arguments: product.productoId,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del producto
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: product.imagenes.isNotEmpty
                                    ? Image.network(
                                        product.imagenes[0],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                              ),
                            ),
                            // Información del producto
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.nombre,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              size: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '#${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '\$${product.precio.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        product.calificacionPromedio.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '(${product.numeroValoraciones})',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Vendedor: ${product.vendedor}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is RecommendationsError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  BlocProvider.of<RecommendationsBloc>(context).add(GetTrendingProductsEvent());
                },
              );
            }
            
            return LoadingIndicator();
          },
        ),
        
        // Pestaña "Descubrimientos"
        BlocBuilder<RecommendationsBloc, RecommendationsState>(
          builder: (context, state) {
            if (state is DiscoveriesLoading) {
              return LoadingIndicator();
            } else if (state is DiscoveriesLoaded) {
              final discoveries = state.discoveries;
              
              if (discoveries.isEmpty) {
                return _buildEmptyState(
                  'No hay descubrimientos disponibles',
                  'Vuelve más tarde para descubrir nuevos productos',
                  Icons.explore,
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<RecommendationsBloc>(context).add(GetDiscoveriesEvent());
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: discoveries.length ~/ 2,
                  itemBuilder: (context, index) {
                    final product1 = discoveries[index * 2];
                    final product2 = index * 2 + 1 < discoveries.length
                        ? discoveries[index * 2 + 1]
                        : null;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Primer producto
                          Expanded(
                            child: ProductCard(
                              product: product1,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/product-details',
                                  arguments: product1.productoId,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          // Segundo producto (si existe)
                          Expanded(
                            child: product2 != null
                                ? ProductCard(
                                    product: product2,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/product-details',
                                        arguments: product2.productoId,
                                      );
                                    },
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else if (state is RecommendationsError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  BlocProvider.of<RecommendationsBloc>(context).add(GetDiscoveriesEvent());
                },
              );
            }
            
            return LoadingIndicator();
          },
        ),
      ],
    ),
  );
}

Widget _buildEmptyState(String title, String subtitle, IconData icon) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
}
