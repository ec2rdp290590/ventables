import 'package:ventables/core/domain/entities/producto.dart';
import 'package:ventables/core/error/exceptions.dart';
import 'package:ventables/core/error/failures.dart';
import 'package:ventables/core/network/network_info.dart';
import 'package:ventables/features/recommendations/data/datasources/recommendation_remote_data_source.dart';
import 'package:ventables/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:dartz/dartz.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
final RecommendationRemoteDataSource remoteDataSource;
final NetworkInfo networkInfo;

RecommendationRepositoryImpl({
  required this.remoteDataSource,
  required this.networkInfo,
});

@override
Future<Either<Failure, List<Producto>>> getPersonalizedRecommendations(int userId) async {
  if (await networkInfo.isConnected) {
    try {
      final recommendations = await remoteDataSource.getPersonalizedRecommendations(userId);
      return Right(recommendations);
    } on ServerException {
      return Left(ServerFailure());
    }
  } else {
    return Left(NetworkFailure());
  }
}

@override
Future<Either<Failure, List<Producto>>> getSimilarProducts(int productId) async {
  if (await networkInfo.isConnected) {
    try {
      final similarProducts = await remoteDataSource.getSimilarProducts(productId);
      return Right(similarProducts);
    } on ServerException {
      return Left(ServerFailure());
    }
  } else {
    return Left(NetworkFailure());
  }
}

@override
Future<Either<Failure, List<Producto>>> getTrendingProducts() async {
  if (await networkInfo.isConnected) {
    try {
      final trendingProducts = await remoteDataSource.getTrendingProducts();
      return Right(trendingProducts);
    } on ServerException {
      return Left(ServerFailure());
    }
  } else {
    return Left(NetworkFailure());
  }
}
}
