import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecase/usecase.dart';
import 'package:number_trivia/core/utils/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<GetTriviaForConcreteNumber>(getTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(getTriviaForRandomNumber);
  }

  FutureOr<void> getTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    await inputEither.fold((failure) async {
      emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
    }, (integer) async {
      emit(Empty());
      emit(Loading());
      final failureOrSuccess =
          await getConcreteNumberTrivia(Params(number: integer));
      await failureOrSuccess.fold((failure) async {
        emit(Error(message: _mapFailureToMessage(failure)));
      }, (trivia) async {
        emit(Loaded(trivia: trivia));
      });
    });
  }

  FutureOr<void> getTriviaForRandomNumber(
      GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    emit(Loading());
    final failureOrSuccess = await getRandomNumberTrivia(NoParams());
    await failureOrSuccess.fold((failure) async {
      emit(Error(message: _mapFailureToMessage(failure)));
    }, (trivia) async {
      emit(Loaded(trivia: trivia));
    });
  }
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
      default :
      return 'UnExpected Error.';
  }
}
