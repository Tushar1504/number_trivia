import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/error/failures.dart';

import '../entities/number_trivia.dart';

abstract class NumberTriviaRepositiory {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int Number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}