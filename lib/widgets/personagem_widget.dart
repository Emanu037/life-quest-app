import 'package:flutter/material.dart';

class PersonagemWidget extends StatelessWidget {
  final String? roupaAtiva;
  final double tamanho;

  const PersonagemWidget({super.key, this.roupaAtiva, this.tamanho = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/gato.png', fit: BoxFit.contain), // Base
          if (roupaAtiva != null)
            Image.asset('assets/$roupaAtiva.png', fit: BoxFit.contain), // Camada
        ],
      ),
    );
  }
}