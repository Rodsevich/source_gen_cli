library libreria.prueba;

import "../lib/src/generation/fileProcessorAnnotations/base.dart"
    show generationAssignment;

@generationAssignment("sorpi", append: false)
@generationAssignment("longa", append: true)
var declaracion = [1, "dos", #tres];
