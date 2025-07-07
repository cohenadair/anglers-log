// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AnglersLogLocalizationsEs extends AnglersLogLocalizations {
  AnglersLogLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get catchFieldFavorite => 'Favorito';

  @override
  String get catchFieldFavoriteDescription =>
      'Si una captura fue una de tus favoritas.';

  @override
  String get saveReportPageFavorites => 'Solo favoritos';

  @override
  String get saveReportPageFavoritesFilter => 'Solo favoritos';

  @override
  String unitsPageCentimeters(String value) {
    return 'Centímetros ($value)';
  }

  @override
  String unitsPageMeters(String value) {
    return 'Metros ($value)';
  }

  @override
  String unitsPageAirVisibilityKilometers(String value) {
    return 'Kilómetros ($value)';
  }

  @override
  String unitsPageWindSpeedKilometers(String value) {
    return 'Kilómetros por hora ($value)';
  }

  @override
  String unitsPageWindSpeedMeters(String value) {
    return 'Metros por segundo ($value)';
  }

  @override
  String get keywordsSpeedMetric => 'kilómetros por hora velocidad del viento';

  @override
  String get inputColorLabel => 'Color';

  @override
  String get appName => 'Registro de Pescadores';

  @override
  String get hashtag => '#AnglersLogApp';

  @override
  String get shareTextAndroid => 'Compartido con #AnglersLogApp para Android.';

  @override
  String get shareTextApple => 'Compartido con #AnglersLogApp para iOS.';

  @override
  String shareLength(String value) {
    return 'Longitud: $value';
  }

  @override
  String shareWeight(String value) {
    return 'Peso: $value';
  }

  @override
  String shareBait(String value) {
    return 'Cebo: $value';
  }

  @override
  String shareBaits(String value) {
    return 'Cebos: $value';
  }

  @override
  String shareCatches(int value) {
    return 'Capturas: $value';
  }

  @override
  String get rateDialogTitle => 'Califica Anglers\' Log';

  @override
  String get rateDialogDescription =>
      '¡Por favor, tómate un momento para escribir una reseña de Anglers\' Log. ¡Todos los comentarios son muy apreciados!';

  @override
  String get rateDialogRate => 'Calificar';

  @override
  String get rateDialogLater => 'Más tarde';

  @override
  String get done => 'Hecho';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get copy => 'Copiar';

  @override
  String get none => 'Ninguno';

  @override
  String get all => 'Todos';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Saltar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get clear => 'Limpiar';

  @override
  String get directions => 'Direcciones';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Volver';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String latLng(String lat, String lng) {
    return 'Lat: $lat, Long: $lng';
  }

  @override
  String latLngNoLabels(String lat, String lng) {
    return '$lat, $lng';
  }

  @override
  String get add => 'Añadir';

  @override
  String get more => 'Más';

  @override
  String get na => 'N/D';

  @override
  String get finish => 'Finalizar';

  @override
  String get by => 'por';

  @override
  String get unknown => 'Desconocido';

  @override
  String get devName => 'Cohen Adair';

  @override
  String numberOfCatches(int numOfCatches) {
    return '$numOfCatches capturas';
  }

  @override
  String get numberOfCatchesSingular => '1 captura';

  @override
  String get unknownSpecies => 'Especie desconocida';

  @override
  String get unknownBait => 'Cebo desconocido';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get share => 'Compartir';

  @override
  String get setPermissionButton => 'Establecer permiso';

  @override
  String get fieldTypeNumber => 'Número';

  @override
  String get fieldTypeBoolean => 'Casilla de verificación';

  @override
  String get fieldTypeText => 'Texto';

  @override
  String inputRequiredMessage(String inputLabel) {
    return '$inputLabel es requerido';
  }

  @override
  String get inputNameLabel => 'Nombre';

  @override
  String get inputGenericRequired => 'Requerido';

  @override
  String get inputDescriptionLabel => 'Descripción';

  @override
  String get inputNotesLabel => 'Notas';

  @override
  String get inputInvalidNumber => 'Entrada de número inválida';

  @override
  String get inputPhotoLabel => 'Foto';

  @override
  String get inputPhotosLabel => 'Agregar fotos';

  @override
  String get inputNotSelected => 'No seleccionado';

  @override
  String get inputEmailLabel => 'Correo electrónico';

  @override
  String get inputInvalidEmail => 'Formato de correo electrónico inválido';

  @override
  String get inputAtmosphere => 'Atmósfera y clima';

  @override
  String get inputFetch => 'Recoger';

  @override
  String get inputAutoFetch => 'Auto-recoger';

  @override
  String get inputCurrentLocation => 'Ubicación actual';

  @override
  String get inputGenericFetchError =>
      'No se puede obtener datos en este momento. Por favor, asegúrate de que tu dispositivo esté conectado a internet y vuelve a intentarlo.';

  @override
  String get fieldWaterClarityLabel => 'Claridad del Agua';

  @override
  String get fieldWaterDepthLabel => 'Profundidad del agua';

  @override
  String get fieldWaterTemperatureLabel => 'Temperatura del agua';

  @override
  String catchListPageTitle(int numOfCatches) {
    return 'Capturas ($numOfCatches)';
  }

  @override
  String get catchListPageSearchHint => 'Buscar capturas';

  @override
  String get catchListPageEmptyListTitle => 'Sin capturas';

  @override
  String get catchListPageEmptyListDescription =>
      'Aún no has agregado ninguna captura. Toca el botón %s para comenzar.';

  @override
  String catchListItemLength(String value) {
    return 'Longitud: $value';
  }

  @override
  String catchListItemWeight(String value) {
    return 'Peso: $value';
  }

  @override
  String get catchListItemNotSet => '-';

  @override
  String catchPageDeleteMessage(String value) {
    return '¿Estás seguro de que deseas eliminar la captura $value? Esto no se puede deshacer.';
  }

  @override
  String catchPageDeleteWithTripMessage(String value) {
    return '$value está asociado con un viaje; ¿Estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get catchPageReleased => 'Liberado';

  @override
  String get catchPageKept => 'Conservado';

  @override
  String catchPageQuantityLabel(int value) {
    return 'Cantidad: $value';
  }

  @override
  String get saveCatchPageNewTitle => 'Nueva captura';

  @override
  String get saveCatchPageEditTitle => 'Editar captura';

  @override
  String get catchFieldTide => 'Marea';

  @override
  String get catchFieldDateTime => 'Fecha y hora';

  @override
  String get catchFieldDate => 'Fecha';

  @override
  String get catchFieldTime => 'Tiempo';

  @override
  String get catchFieldPeriod => 'Hora del día';

  @override
  String get catchFieldPeriodDescription =>
      'Como el amanecer, la mañana, el atardecer, etc.';

  @override
  String get catchFieldSeason => 'Temporada';

  @override
  String get catchFieldSeasonDescription =>
      'Invierno, primavera, verano u otoño.';

  @override
  String get catchFieldImages => 'Fotos';

  @override
  String get catchFieldFishingSpot => 'Lugar de pesca';

  @override
  String get catchFieldFishingSpotDescription =>
      'Coordenadas de donde se realizó una captura.';

  @override
  String get catchFieldBait => 'Cebo';

  @override
  String get catchFieldAngler => 'Pescador';

  @override
  String get catchFieldGear => 'Equipo';

  @override
  String get catchFieldMethodsDescription =>
      'La forma en que se realizó una captura.';

  @override
  String get catchFieldNoMethods => 'Sin métodos de pesca';

  @override
  String get catchFieldNoBaits => 'Sin cebos';

  @override
  String get catchFieldNoGear => 'Sin equipo';

  @override
  String get catchFieldCatchAndRelease => 'Captura y liberación';

  @override
  String get catchFieldCatchAndReleaseDescription =>
      'Si esta captura fue liberada o no.';

  @override
  String get catchFieldTideHeightLabel => 'Altura de la marea';

  @override
  String get catchFieldLengthLabel => 'Longitud';

  @override
  String get catchFieldWeightLabel => 'Peso';

  @override
  String get catchFieldQuantityLabel => 'Cantidad';

  @override
  String get catchFieldQuantityDescription =>
      'El número de especies seleccionadas capturadas.';

  @override
  String get catchFieldNotesLabel => 'Notas';

  @override
  String get saveReportPageNewTitle => 'Nuevo informe';

  @override
  String get saveReportPageEditTitle => 'Editar informe';

  @override
  String get saveReportPageNameExists => 'El nombre del informe ya existe';

  @override
  String get saveReportPageTypeTitle => 'Tipo';

  @override
  String get saveReportPageComparison => 'Comparación';

  @override
  String get saveReportPageSummary => 'Resumen';

  @override
  String get saveReportPageStartDateRangeLabel => 'Comparar';

  @override
  String get saveReportPageEndDateRangeLabel => 'a';

  @override
  String get saveReportPageAllAnglers => 'Todos los pescadores';

  @override
  String get saveReportPageAllWaterClarities => 'Todas las claridades del agua';

  @override
  String get saveReportPageAllSpecies => 'Todas las especies';

  @override
  String get saveReportPageAllBaits => 'Todos los cebos';

  @override
  String get saveReportPageAllGear => 'Todo el equipo';

  @override
  String get saveReportPageAllBodiesOfWater => 'Todos los cuerpos de agua';

  @override
  String get saveReportPageAllFishingSpots => 'Todos los lugares de pesca';

  @override
  String get saveReportPageAllMethods => 'Todos los métodos de pesca';

  @override
  String get saveReportPageCatchAndRelease => 'Solo captura y liberación';

  @override
  String get saveReportPageCatchAndReleaseFilter => 'Solo captura y liberación';

  @override
  String get saveReportPageAllWindDirections =>
      'Todas las direcciones del viento';

  @override
  String get saveReportPageAllSkyConditions =>
      'Todas las condiciones del cielo';

  @override
  String get saveReportPageAllMoonPhases => 'Todas las fases lunares';

  @override
  String get saveReportPageAllTideTypes => 'Todas las mareas';

  @override
  String get photosPageMenuLabel => 'Fotos';

  @override
  String photosPageTitle(int numOfPhotos) {
    return 'Fotos ($numOfPhotos)';
  }

  @override
  String get photosPageEmptyTitle => 'Sin fotos';

  @override
  String get photosPageEmptyDescription =>
      'Todas las fotos adjuntas a las capturas se mostrarán aquí. Para agregar una captura, toca el ícono %s.';

  @override
  String baitListPageTitle(int numOfBaits) {
    return 'Cebos ($numOfBaits)';
  }

  @override
  String get baitListPageOtherCategory => 'Sin categoría';

  @override
  String get baitListPageSearchHint => 'Buscar cebos';

  @override
  String baitListPageDeleteMessage(String bait, int numOfCatches) {
    return '$bait está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String baitListPageDeleteMessageSingular(String bait) {
    return '$bait está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get baitListPageEmptyListTitle => 'Sin cebos';

  @override
  String get baitListPageEmptyListDescription =>
      'Aún no has añadido cebos. Toca el botón %s para comenzar.';

  @override
  String get baitsSummaryEmpty =>
      'Cuando se añadan cebos a tu registro, aquí se mostrará un resumen de sus capturas.';

  @override
  String baitListPageVariantsLabel(int numOfVariants) {
    return '$numOfVariants variantes';
  }

  @override
  String get baitListPageVariantLabel => '1 variante';

  @override
  String get saveBaitPageNewTitle => 'Nuevo cebo';

  @override
  String get saveBaitPageEditTitle => 'Editar cebo';

  @override
  String get saveBaitPageCategoryLabel => 'Categoría de cebo';

  @override
  String get saveBaitPageBaitExists =>
      'Un cebo con estas propiedades ya existe. Por favor, cambie al menos un campo e intente de nuevo.';

  @override
  String get saveBaitPageVariants => 'Variantes';

  @override
  String get saveBaitPageDeleteVariantSingular =>
      'Esta variante está asociada con 1 captura; ¿está seguro de que desea eliminarla? Esto no se puede deshacer.';

  @override
  String saveBaitPageDeleteVariantPlural(int numOfCatches) {
    return 'Esta variante está asociada con $numOfCatches capturas; ¿está seguro de que desea eliminarla? Esto no se puede deshacer.';
  }

  @override
  String get saveBaitCategoryPageNewTitle => 'Nueva categoría de cebo';

  @override
  String get saveBaitCategoryPageEditTitle => 'Editar categoría de cebo';

  @override
  String get saveBaitCategoryPageExistsMessage =>
      'La categoría de cebo ya existe';

  @override
  String baitCategoryListPageTitle(int numOfCategories) {
    return 'Categorías de Cebos ($numOfCategories)';
  }

  @override
  String baitCategoryListPageDeleteMessage(String bait, int numOfBaits) {
    return '$bait está asociado con $numOfBaits cebos; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String baitCategoryListPageDeleteMessageSingular(String category) {
    return '$category está asociado con 1 cebo; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get baitCategoryListPageSearchHint => 'Buscar categorías de cebos';

  @override
  String get baitCategoryListPageEmptyListTitle => 'No hay categorías de cebos';

  @override
  String get baitCategoryListPageEmptyListDescription =>
      'Aún no has agregado ninguna categoría de cebos. Toca el botón %s para comenzar.';

  @override
  String get saveAnglerPageNewTitle => 'Nuevo pescador';

  @override
  String get saveAnglerPageEditTitle => 'Editar pescador';

  @override
  String get saveAnglerPageExistsMessage => 'El pescador ya existe';

  @override
  String anglerListPageTitle(int numOfAnglers) {
    return 'Pescadores ($numOfAnglers)';
  }

  @override
  String anglerListPageDeleteMessage(String angler, int numOfCatches) {
    return '$angler está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlas? Esto no se puede deshacer.';
  }

  @override
  String anglerListPageDeleteMessageSingular(String angler) {
    return '$angler está asociado con 1 captura; ¿estás seguro de que deseas eliminarla? Esto no se puede deshacer.';
  }

  @override
  String get anglerListPageSearchHint => 'Buscar pescadores';

  @override
  String get anglerListPageEmptyListTitle => 'No hay Pescadores';

  @override
  String get anglerListPageEmptyListDescription =>
      'Aún no has agregado ningún pescador. Toca el botón %s para comenzar.';

  @override
  String get anglersSummaryEmpty =>
      'Cuando se agreguen pescadores a tu registro, se mostrará aquí un resumen de sus capturas.';

  @override
  String get saveMethodPageNewTitle => 'Nuevo método de pesca';

  @override
  String get saveMethodPageEditTitle => 'Editar método de pesca';

  @override
  String get saveMethodPageExistsMessage => 'El método de pesca ya existe';

  @override
  String methodListPageTitle(int numOfMethods) {
    return 'Métodos de pesca ($numOfMethods)';
  }

  @override
  String methodListPageDeleteMessage(String method, int numOfCatches) {
    return '$method está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String methodListPageDeleteMessageSingular(String method) {
    return '$method está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get methodListPageSearchHint => 'Buscar métodos de pesca';

  @override
  String get methodListPageEmptyListTitle => 'Sin métodos de pesca';

  @override
  String get methodListPageEmptyListDescription =>
      'Aún no has agregado ningún método de pesca. Toca el botón %s para comenzar.';

  @override
  String get methodSummaryEmpty =>
      'Cuando se agreguen métodos de pesca a tu registro, aquí se mostrará un resumen de sus capturas.';

  @override
  String get saveWaterClarityPageNewTitle => 'Nueva claridad del agua';

  @override
  String get saveWaterClarityPageEditTitle => 'Editar claridad del agua';

  @override
  String get saveWaterClarityPageExistsMessage =>
      'La claridad del agua ya existe';

  @override
  String waterClarityListPageTitle(int numOfClarities) {
    return 'Claridades de agua ($numOfClarities)';
  }

  @override
  String waterClarityListPageDeleteMessage(String clarity, int numOfCatches) {
    return '$clarity está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String waterClarityListPageDeleteMessageSingular(String clarity) {
    return '$clarity está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get waterClarityListPageSearchHint => 'Buscar claridades de agua';

  @override
  String get waterClarityListPageEmptyListTitle => 'Sin claridades de agua';

  @override
  String get waterClarityListPageEmptyListDescription =>
      'Aún no has agregado ninguna claridad de agua. Toca el botón %s para comenzar.';

  @override
  String get waterClaritiesSummaryEmpty =>
      'Cuando se agreguen claridades de agua a su registro, se mostrará un resumen de sus capturas aquí.';

  @override
  String get statsPageMenuTitle => 'Estadísticas';

  @override
  String get statsPageTitle => 'Estadísticas';

  @override
  String get statsPageNewReport => 'Nuevo informe';

  @override
  String get statsPageSpeciesSummary => 'Resumen de especies';

  @override
  String get statsPageCatchSummary => 'Resumen de capturas';

  @override
  String get statsPageAnglerSummary => 'Resumen del pescador';

  @override
  String get statsPageBaitSummary => 'Resumen del cebo';

  @override
  String statsPageBaitVariantAllLabel(String bait) {
    return '$bait (Todas las Variantes)';
  }

  @override
  String get statsPageBodyOfWaterSummary => 'Resumen del cuerpo de agua';

  @override
  String get statsPageFishingSpotSummary => 'Resumen del lugar de pesca';

  @override
  String get statsPageMethodSummary => 'Resumen del método de pesca';

  @override
  String get statsPageMoonPhaseSummary => 'Resumen de la fase lunar';

  @override
  String get statsPagePeriodSummary => 'Resumen de la hora del día';

  @override
  String get statsPageSeasonSummary => 'Resumen de la temporada';

  @override
  String get statsPageTideSummary => 'Resumen de mareas';

  @override
  String get statsPageWaterClaritySummary => 'Resumen de claridad del agua';

  @override
  String get statsPageGearSummary => 'Resumen del equipo';

  @override
  String get statsPagePersonalBests => 'Mejores personales';

  @override
  String get personalBestsTrip => 'Mejor viaje';

  @override
  String get personalBestsLongest => 'Más largo';

  @override
  String get personalBestsHeaviest => 'Más pesado';

  @override
  String get personalBestsSpeciesByLength => 'Especies por longitud';

  @override
  String get personalBestsSpeciesByLengthLabel => 'Más largo';

  @override
  String get personalBestsSpeciesByWeight => 'Especies por peso';

  @override
  String get personalBestsSpeciesByWeightLabel => 'Más pesado';

  @override
  String get personalBestsShowAllSpecies => 'Ver todas las especies';

  @override
  String get personalBestsAverage => 'Promedio';

  @override
  String get personalBestsNoDataTitle => 'Sin datos';

  @override
  String get personalBestsNoDataDescription =>
      'No se pueden determinar tus mejores marcas personales para el rango de fechas seleccionado. Asegúrate de haber agregado un viaje o de haber agregado una captura con un valor de longitud o peso.';

  @override
  String get reportViewEmptyLog => 'Registro vacío';

  @override
  String get reportViewEmptyLogDescription =>
      'Aún no has agregado ninguna captura. Para agregar una captura, toca el ícono %s.';

  @override
  String get reportViewNoCatches => 'No se encontraron capturas';

  @override
  String get reportViewNoCatchesDescription =>
      'No se encontraron capturas en el rango de fechas seleccionado.';

  @override
  String get reportViewNoCatchesReportDescription =>
      'No se encontraron capturas en el rango de fechas del informe seleccionado.';

  @override
  String get reportSummaryCatchTitle => 'Resumen de capturas';

  @override
  String get reportSummaryPerSpecies => 'Por especie';

  @override
  String get reportSummaryPerFishingSpot => 'Por lugar de pesca';

  @override
  String get reportSummaryPerBait => 'Por cebo';

  @override
  String get reportSummaryPerAngler => 'Por pescador';

  @override
  String get reportSummaryPerBodyOfWater => 'Por cuerpo de agua';

  @override
  String get reportSummaryPerMethod => 'Por método de pesca';

  @override
  String get reportSummaryPerMoonPhase => 'Por fase lunar';

  @override
  String get reportSummaryPerPeriod => 'Por hora del día';

  @override
  String get reportSummaryPerSeason => 'Por temporada';

  @override
  String get reportSummaryPerTideType => 'Por marea';

  @override
  String get reportSummaryPerWaterClarity => 'Por claridad del agua';

  @override
  String get reportSummarySinceLastCatch => 'Desde la última captura';

  @override
  String get reportSummaryNumberOfCatches => 'Número de capturas';

  @override
  String get reportSummaryFilters => 'Filtros';

  @override
  String get reportSummaryViewSpecies => 'Ver todas las especies';

  @override
  String get reportSummaryPerSpeciesDescription =>
      'Viendo el número de capturas por especie.';

  @override
  String get reportSummaryViewFishingSpots => 'Ver todos los lugares de pesca';

  @override
  String get reportSummaryPerFishingSpotDescription =>
      'Viendo el número de capturas por lugar de pesca.';

  @override
  String get reportSummaryViewBaits => 'Ver todos los cebos';

  @override
  String get reportSummaryPerBaitDescription =>
      'Viendo el número de capturas por cebo.';

  @override
  String get reportSummaryViewMoonPhases => 'Ver todas las fases lunares';

  @override
  String get reportSummaryPerMoonPhaseDescription =>
      'Viendo el número de capturas por fase lunar.';

  @override
  String get reportSummaryViewTides => 'Ver todos los tipos de marea';

  @override
  String get reportSummaryPerTideDescription =>
      'Viendo el número de capturas por tipo de marea.';

  @override
  String get reportSummaryViewAnglers => 'Ver todos los pescadores';

  @override
  String get reportSummaryPerAnglerDescription =>
      'Viendo el número de capturas por pescador.';

  @override
  String get reportSummaryViewBodiesOfWater => 'Ver todos los cuerpos de agua';

  @override
  String get reportSummaryPerBodyOfWaterDescription =>
      'Viendo el número de capturas por cuerpo de agua.';

  @override
  String get reportSummaryViewMethods => 'Ver todos los métodos de pesca';

  @override
  String get reportSummaryPerMethodDescription =>
      'Viendo el número de capturas por método de pesca.';

  @override
  String get reportSummaryViewPeriods => 'Ver todos los momentos del día';

  @override
  String get reportSummaryPerPeriodDescription =>
      'Viendo el número de capturas por hora del día.';

  @override
  String get reportSummaryViewSeasons => 'Ver todas las temporadas';

  @override
  String get reportSummaryPerSeasonDescription =>
      'Viendo el número de capturas por temporada.';

  @override
  String get reportSummaryViewWaterClarities =>
      'Ver todas las claridades del agua';

  @override
  String get reportSummaryPerWaterClarityDescription =>
      'Viendo el número de capturas por claridad del agua.';

  @override
  String get reportSummaryPerHour => 'Por hora';

  @override
  String get reportSummaryViewAllHours => 'Ver todas las horas';

  @override
  String get reportSummaryViewAllHoursDescription =>
      'Viendo el número de capturas para cada hora del día.';

  @override
  String get reportSummaryPerMonth => 'Por mes';

  @override
  String get reportSummaryViewAllMonths => 'Ver todos los meses';

  @override
  String get reportSummaryViewAllMonthsDescription =>
      'Viendo el número de capturas para cada mes del año.';

  @override
  String get reportSummaryPerGear => 'Por equipo';

  @override
  String get reportSummaryViewGear => 'Ver todo el equipo';

  @override
  String get reportSummaryPerGearDescription =>
      'Viendo el número de capturas por equipo.';

  @override
  String get morePageTitle => 'Más';

  @override
  String get morePageRateApp => 'Califica Anglers\' Log';

  @override
  String get morePagePro => 'Anglers\' Log Pro';

  @override
  String get morePageRateErrorApple =>
      'El dispositivo no tiene instalada la App Store.';

  @override
  String get morePageRateErrorAndroid =>
      'El dispositivo no tiene instalada ninguna aplicación de navegador web.';

  @override
  String tripListPageTitle(int numOfTrips) {
    return 'Viajes ($numOfTrips)';
  }

  @override
  String get tripListPageSearchHint => 'Buscar viajes';

  @override
  String get tripListPageEmptyListTitle => 'Sin viajes';

  @override
  String get tripListPageEmptyListDescription =>
      'Aún no has agregado ningún viaje. Toca el botón %s para comenzar.';

  @override
  String tripListPageDeleteMessage(String trip) {
    return '¿Está seguro de que desea eliminar el viaje $trip? Esto no se puede deshacer.';
  }

  @override
  String get saveTripPageEditTitle => 'Editar viaje';

  @override
  String get saveTripPageNewTitle => 'Nuevo viaje';

  @override
  String get saveTripPageAutoSetTitle => 'Auto-establecer campos';

  @override
  String get saveTripPageAutoSetDescription =>
      'Establecer automáticamente los campos aplicables cuando se seleccionen las capturas.';

  @override
  String get saveTripPageStartDate => 'Fecha de inicio';

  @override
  String get saveTripPageStartTime => 'Hora de inicio';

  @override
  String get saveTripPageStartDateTime => 'Fecha y hora de inicio';

  @override
  String get saveTripPageEndDate => 'Fecha de finalización';

  @override
  String get saveTripPageEndTime => 'Hora de finalización';

  @override
  String get saveTripPageEndDateTime => 'Fecha y hora de finalización';

  @override
  String get saveTripPageAllDay => 'Todo el dia';

  @override
  String get saveTripPageCatchesDesc => 'Trofeos registrados en este viaje.';

  @override
  String get saveTripPageNoCatches => 'Sin capturas';

  @override
  String get saveTripPageNoBodiesOfWater => 'Sin cuerpos de agua';

  @override
  String get saveTripPageNoGpsTrails => 'Sin rutas GPS';

  @override
  String get tripCatchesPerSpecies => 'Capturas por especie';

  @override
  String get tripCatchesPerFishingSpot => 'Capturas por lugar de pesca';

  @override
  String get tripCatchesPerAngler => 'Capturas por pescador';

  @override
  String get tripCatchesPerBait => 'Capturas por cebo';

  @override
  String get tripSkunked => 'Sin capturas';

  @override
  String get settingsPageTitle => 'Configuración';

  @override
  String get settingsPageFetchAtmosphereTitle => 'Auto-obtener clima';

  @override
  String get settingsPageFetchAtmosphereDescription =>
      'Obtener automáticamente datos de atmósfera y clima al agregar nuevas capturas y viajes.';

  @override
  String get settingsPageFetchTideTitle => 'Auto-obtener mareas';

  @override
  String get settingsPageFetchTideDescription =>
      'Obtener automáticamente datos de mareas al agregar nuevas capturas.';

  @override
  String get settingsPageLogout => 'Cerrar sesión';

  @override
  String get settingsPageLogoutConfirmMessage =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get settingsPageAbout => 'Acerca de, términos y privacidad';

  @override
  String get settingsPageFishingSpotDistanceTitle =>
      'Distancia del lugar de pesca automático';

  @override
  String get settingsPageFishingSpotDistanceDescription =>
      'La distancia dentro de la cual se seleccionan automáticamente los lugares de pesca al agregar capturas.';

  @override
  String get settingsPageMinGpsTrailDistanceTitle => 'Distancia del rastro GPS';

  @override
  String get settingsPageMinGpsTrailDistanceDescription =>
      'La distancia mínima entre puntos en un rastro GPS.';

  @override
  String get settingsPageThemeTitle => 'Tema';

  @override
  String get settingsPageThemeSystem => 'Sistema';

  @override
  String get settingsPageThemeLight => 'Ligero';

  @override
  String get settingsPageThemeDark => 'Oscuro';

  @override
  String get settingsPageThemeSelect => 'Seleccionar tema';

  @override
  String get unitsPageTitle => 'Unidades de medida';

  @override
  String get unitsPageCatchLength => 'Longitud de captura';

  @override
  String unitsPageFractionalInches(String value) {
    return 'Pulgadas fraccionarias ($value)';
  }

  @override
  String unitsPageInches(String value) {
    return 'Pulgadas ($value)';
  }

  @override
  String get unitsPageCatchWeight => 'Peso de captura';

  @override
  String unitsPageCatchWeightPoundsOunces(String value) {
    return 'Libras y onzas ($value)';
  }

  @override
  String unitsPageCatchWeightPounds(String value) {
    return 'Libras ($value)';
  }

  @override
  String unitsPageCatchWeightKilograms(String value) {
    return 'Kilogramos ($value)';
  }

  @override
  String unitsPageWaterTemperatureFahrenheit(String value) {
    return 'Fahrenheit ($value)';
  }

  @override
  String unitsPageWaterTemperatureCelsius(String value) {
    return 'Celsius ($value)';
  }

  @override
  String unitsPageFeetInches(String value) {
    return 'Pies y pulgadas ($value)';
  }

  @override
  String unitsPageFeet(String value) {
    return 'Pies ($value)';
  }

  @override
  String unitsPageAirTemperatureFahrenheit(String value) {
    return 'Fahrenheit ($value)';
  }

  @override
  String unitsPageAirTemperatureCelsius(String value) {
    return 'Celsius ($value)';
  }

  @override
  String unitsPageAirPressureInHg(String value) {
    return 'Pulgada de mercurio ($value)';
  }

  @override
  String unitsPageAirPressurePsi(String value) {
    return 'Libras por pulgada cuadrada ($value)';
  }

  @override
  String unitsPageAirPressureMillibars(String value) {
    return 'Milibares ($value)';
  }

  @override
  String unitsPageAirVisibilityMiles(String value) {
    return 'Millas ($value)';
  }

  @override
  String unitsPageWindSpeedMiles(String value) {
    return 'Millas por hora ($value)';
  }

  @override
  String get unitsPageDistanceTitle => 'Distancia';

  @override
  String get unitsPageRodLengthTitle => 'Longitud de la caña';

  @override
  String get unitsPageLeaderLengthTitle => 'Longitud del líder';

  @override
  String get unitsPageTippetLengthTitle => 'Longitud del tippet';

  @override
  String get mapPageMenuLabel => 'Mapa';

  @override
  String mapPageDeleteFishingSpot(String spot, int numOfCatches) {
    return '$spot está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String mapPageDeleteFishingSpotSingular(String spot) {
    return '$spot está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String mapPageDeleteFishingSpotNoName(int numOfCatches) {
    return 'Este lugar de pesca está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get mapPageDeleteFishingSpotNoNameSingular =>
      'Este lugar de pesca está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';

  @override
  String get mapPageAddCatch => 'Agregar captura';

  @override
  String get mapPageSearchHint => 'Buscar lugares de pesca';

  @override
  String get mapPageDroppedPin => 'Nuevo lugar de pesca';

  @override
  String get mapPageMapTypeLight => 'Ligero';

  @override
  String get mapPageMapTypeSatellite => 'Satélite';

  @override
  String get mapPageMapTypeDark => 'Oscuro';

  @override
  String get mapPageErrorGettingLocation =>
      'No se puede recuperar la ubicación actual. Asegúrate de que los servicios de ubicación de tu dispositivo estén activados y vuelve a intentarlo más tarde.';

  @override
  String get mapPageErrorOpeningDirections =>
      'No hay aplicaciones de navegación disponibles en este dispositivo.';

  @override
  String get mapPageAppleMaps => 'Apple Maps™';

  @override
  String get mapPageGoogleMaps => 'Google Maps™';

  @override
  String get mapPageWaze => 'Waze™';

  @override
  String get mapPageMapTypeTooltip => 'Elegir tipo de mapa';

  @override
  String get mapPageMyLocationTooltip => 'Mostrar mi ubicación';

  @override
  String get mapPageShowAllTooltip => 'Mostrar todos los lugares de pesca';

  @override
  String get mapPageStartTrackingTooltip => 'Iniciar ruta GPS';

  @override
  String get mapPageStopTrackingTooltip => 'Detener ruta GPS';

  @override
  String get mapPageAddTooltip => 'Agregar lugar de pesca';

  @override
  String get saveFishingSpotPageNewTitle => 'Nuevo lugar de pesca';

  @override
  String get saveFishingSpotPageEditTitle => 'Editar lugar de pesca';

  @override
  String get saveFishingSpotPageBodyOfWaterLabel => 'Cuerpo de Agua';

  @override
  String get saveFishingSpotPageCoordinatesLabel => 'Coordenadas';

  @override
  String get formPageManageFieldText => 'Gestionar campos';

  @override
  String get formPageAddCustomFieldNote =>
      'Para agregar un campo personalizado, toca el ícono %s.';

  @override
  String get formPageManageFieldsNote =>
      'Para gestionar campos, toca el ícono %s.';

  @override
  String get formPageManageFieldsProDescription =>
      'Debes ser suscriptor de Anglers\' Log Pro para usar campos personalizados.';

  @override
  String get formPageManageUnits => 'Gestionar unidades';

  @override
  String get formPageConfirmBackDesc =>
      'Cualquier cambio no guardado se perderá. ¿Estás seguro de que deseas descartar los cambios y volver?';

  @override
  String get formPageConfirmBackAction => 'Descartar';

  @override
  String get saveCustomEntityPageNewTitle => 'Nuevo campo';

  @override
  String get saveCustomEntityPageEditTitle => 'Editar campo';

  @override
  String get saveCustomEntityPageNameExists => 'El nombre del campo ya existe';

  @override
  String customEntityListPageTitle(int numOfFields) {
    return 'Campos Personalizados ($numOfFields)';
  }

  @override
  String customEntityListPageDelete(
      String field, int numOfCatches, int numOfBaits) {
    return 'El campo personalizado $field ya no estará asociado con las capturas ($numOfCatches) o cebos ($numOfBaits), ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get customEntityListPageSearchHint => 'Buscar campos';

  @override
  String get customEntityListPageEmptyListTitle => 'Sin Campos Personalizados';

  @override
  String get customEntityListPageEmptyListDescription =>
      'Aún no has agregado ningún campo personalizado. Toca el botón %s para comenzar.';

  @override
  String get imagePickerConfirmDelete =>
      '¿Estás seguro de que deseas eliminar esta foto?';

  @override
  String get imagePickerPageNoPhotosFoundTitle => 'No se encontraron fotos';

  @override
  String get imagePickerPageNoPhotosFound =>
      'Intenta cambiar la fuente de la foto desde el menú desplegable de arriba.';

  @override
  String get imagePickerPageOpenCameraLabel => 'Abrir cámara';

  @override
  String get imagePickerPageCameraLabel => 'Cámara';

  @override
  String get imagePickerPageGalleryLabel => 'Galería';

  @override
  String get imagePickerPageBrowseLabel => 'Explorar';

  @override
  String imagePickerPageSelectedLabel(int numSelected, int numTotal) {
    return '$numSelected / $numTotal seleccionados';
  }

  @override
  String get imagePickerPageInvalidSelectionSingle =>
      'Debes seleccionar un archivo de imagen.';

  @override
  String get imagePickerPageInvalidSelectionPlural =>
      'Debes seleccionar archivos de imagen.';

  @override
  String get imagePickerPageNoPermissionTitle => 'Permiso requerido';

  @override
  String get imagePickerPageNoPermissionMessage =>
      'Para agregar fotos, debes otorgar permiso a Anglers\' Log para acceder a tu biblioteca de fotos. Para hacerlo, abre la configuración de tu dispositivo.\n\nAlternativamente, puedes cambiar la fuente de fotos desde el menú desplegable arriba.';

  @override
  String get imagePickerPageOpenSettings => 'Abrir configuración';

  @override
  String get imagePickerPageImageDownloadError =>
      'Error al adjuntar la foto. Asegúrate de estar conectado a Internet y vuelve a intentarlo.';

  @override
  String get imagePickerPageImagesDownloadError =>
      'Error al adjuntar una o más fotos. Asegúrate de estar conectado a Internet y vuelve a intentarlo.';

  @override
  String reportListPageConfirmDelete(String report) {
    return '¿Estás seguro de que deseas eliminar el informe $report? Esto no se puede deshacer.';
  }

  @override
  String get reportListPageReportTitle => 'Informes personalizados';

  @override
  String get reportListPageReportAddNote =>
      'Para agregar un informe personalizado, toca el ícono %s.';

  @override
  String get reportListPageReportsProDescription =>
      'Debes ser suscriptor Pro de Anglers\' Log para ver informes personalizados.';

  @override
  String get saveSpeciesPageNewTitle => 'Nueva especie';

  @override
  String get saveSpeciesPageEditTitle => 'Editar especie';

  @override
  String get saveSpeciesPageExistsError => 'La especie ya existe';

  @override
  String speciesListPageTitle(int numOfSpecies) {
    return 'Especies ($numOfSpecies)';
  }

  @override
  String speciesListPageConfirmDelete(String species) {
    return '$species está asociado con 0 capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String speciesListPageCatchDeleteErrorSingular(String species) {
    return '$species está asociado con 1 captura y no se puede eliminar.';
  }

  @override
  String speciesListPageCatchDeleteErrorPlural(
      String species, int numOfCatches) {
    return '$species está asociado con $numOfCatches capturas y no se puede eliminar.';
  }

  @override
  String get speciesListPageSearchHint => 'Buscar especies';

  @override
  String get speciesListPageEmptyListTitle => 'Sin especies';

  @override
  String get speciesListPageEmptyListDescription =>
      'Aún no has agregado ninguna especie. Toca el botón %s para comenzar.';

  @override
  String get fishingSpotPickerPageHint =>
      'Mantén presionado el mapa para elegir coordenadas exactas o selecciona un lugar de pesca existente.';

  @override
  String fishingSpotListPageTitle(int numOfSpots) {
    return 'Lugares de pesca ($numOfSpots)';
  }

  @override
  String get fishingSpotListPageSearchHint => 'Buscar lugares de pesca';

  @override
  String get fishingSpotListPageEmptyListTitle => 'Sin lugares de pesca';

  @override
  String get fishingSpotListPageEmptyListDescription =>
      'Para agregar un lugar de pesca, toca el botón %s en el mapa y guarda el pin dejado.';

  @override
  String get fishingSpotsSummaryEmpty =>
      'Cuando se agreguen lugares de pesca a tu registro, aquí se mostrará un resumen de sus capturas.';

  @override
  String get fishingSpotListPageNoBodyOfWater => 'Sin cuerpo de agua';

  @override
  String get fishingSpotMapAddSpotHelp =>
      'Mantén presionado en cualquier parte del mapa para dejar un pin y agregar un lugar de pesca.';

  @override
  String get editCoordinatesHint =>
      'Arrastra el mapa para actualizar las coordenadas del lugar de pesca.';

  @override
  String get feedbackPageTitle => 'Enviar comentarios';

  @override
  String get feedbackPageSend => 'Enviar';

  @override
  String get feedbackPageMessage => 'Mensaje';

  @override
  String get feedbackPageBugType => 'Bicho';

  @override
  String get feedbackPageSuggestionType => 'Sugerencia';

  @override
  String get feedbackPageFeedbackType => 'Retroalimentación';

  @override
  String get feedbackPageErrorSending =>
      'Error al enviar comentarios. Por favor, inténtalo de nuevo más tarde o envía un correo a support@anglerslog.ca directamente.';

  @override
  String get feedbackPageConnectionError =>
      'Sin conexión a internet. Por favor, verifica tu conexión e inténtalo de nuevo.';

  @override
  String get feedbackPageSending => 'Enviando comentarios...';

  @override
  String get backupPageMoreTitle => 'Copia de seguridad y restauración';

  @override
  String get importPageMoreTitle => 'Importación heredada';

  @override
  String get importPageTitle => 'Importación heredada';

  @override
  String get importPageDescription =>
      'La importación heredada requiere que elijas un archivo de respaldo (.zip) que creaste con una versión anterior de Anglers\' Log. Los datos heredados importados se añaden a tu registro existente.\n\nEl proceso de importación puede tardar varios minutos.';

  @override
  String get importPageImportingImages => 'Copiando imágenes...';

  @override
  String get importPageImportingData => 'Copiando datos de pesca...';

  @override
  String get importPageSuccess => '¡Datos importados con éxito!';

  @override
  String get importPageError =>
      'Hubo un error al importar tus datos. Si el archivo de respaldo que elegiste fue creado usando Anglers\' Log, por favor envíanoslo para su investigación.';

  @override
  String get importPageErrorWarningMessage =>
      'Al presionar enviar, Anglers\' Log enviará todos tus datos de pesca (excluyendo fotos). Tus datos no se compartirán fuera de la organización de Anglers\' Log.';

  @override
  String get importPageErrorTitle => 'Error de importación';

  @override
  String get dataImporterChooseFile => 'Elegir archivo';

  @override
  String get dataImporterStart => 'Iniciar';

  @override
  String get migrationPageMoreTitle => 'Migración legado';

  @override
  String get migrationPageTitle => 'Migración de datos';

  @override
  String get onboardingMigrationPageDescription =>
      'Esta es tu primera vez abriendo Anglers\' Log desde la actualización a 2.0. Haz clic en el botón de abajo para comenzar el proceso de migración de datos.';

  @override
  String get migrationPageDescription =>
      'Tienes datos heredados que necesitan ser migrados a Anglers\' Log 2.0. Haz clic en el botón de abajo para comenzar.';

  @override
  String get onboardingMigrationPageError =>
      'Se produjo un error inesperado al migrar tus datos a Anglers\' Log 2.0. Por favor, envíanos el informe de error y lo investigaremos lo antes posible. Ten en cuenta que ninguno de tus datos se ha perdido. Visita la página de Configuración para volver a intentar la migración de datos una vez que se haya resuelto el problema.';

  @override
  String get migrationPageError =>
      'Se produjo un error inesperado al migrar tus datos a Anglers\' Log 2.0. Por favor, envíanos el informe de error y lo investigaremos lo antes posible. Ten en cuenta que ninguno de tus datos antiguos se ha perdido. Por favor, vuelve a esta página para intentar la migración de datos después de que se haya resuelto el problema.';

  @override
  String get migrationPageLoading => 'Migrando datos a Anglers\' Log 2.0...';

  @override
  String get migrationPageSuccess => '¡Datos migrados con éxito!';

  @override
  String get migrationPageNothingToDoDescription =>
      'La migración de datos es el proceso de convertir datos heredados de versiones antiguas de Anglers\' Log al formato de datos utilizado por las nuevas versiones.';

  @override
  String get migrationPageNothingToDoSuccess =>
      '¡No tienes datos heredados para migrar!';

  @override
  String get migrationPageFeedbackTitle => 'Error de migración';

  @override
  String get anglerNameLabel => 'Pescador';

  @override
  String get onboardingJourneyWelcomeTitle => 'Bienvenido';

  @override
  String get onboardingJourneyStartDescription =>
      '¡Bienvenido a Anglers\' Log! Comencemos por averiguar qué tipo de datos deseas rastrear.';

  @override
  String get onboardingJourneyStartButton => 'Comenzar';

  @override
  String get onboardingJourneySkip => 'No gracias, aprenderé sobre la marcha.';

  @override
  String get onboardingJourneyCatchFieldDescription =>
      '¿Qué quieres saber cuando registras una captura?';

  @override
  String get onboardingJourneyManageFieldsTitle => 'Gestionar campos';

  @override
  String get onboardingJourneyManageFieldsDescription =>
      'Gestiona campos predeterminados o agrega campos personalizados en cualquier momento al agregar o editar equipo, una captura, cebo, viaje o clima.';

  @override
  String get onboardingJourneyManageFieldsSpecies => 'Trucha arcoíris';

  @override
  String get onboardingJourneyLocationAccessTitle => 'Acceso a la ubicación';

  @override
  String get onboardingJourneyLocationAccessDescription =>
      'El registro de pescadores utiliza servicios de ubicación para mostrar tu ubicación actual en el mapa de la aplicación, para crear automáticamente lugares de pesca al agregar capturas y para crear rutas GPS mientras pescas.';

  @override
  String get onboardingJourneyHowToFeedbackTitle => 'Enviar comentarios';

  @override
  String get onboardingJourneyHowToFeedbackDescription =>
      'Informa un problema, sugiere una función o envíanos tus comentarios en cualquier momento. ¡Nos encantaría saber de ti!';

  @override
  String get onboardingJourneyNotNow => 'No ahora';

  @override
  String get emptyListPlaceholderNoResultsTitle =>
      'No se encontraron resultados';

  @override
  String get emptyListPlaceholderNoResultsDescription =>
      'Por favor, ajusta tu filtro de búsqueda para encontrar lo que estás buscando.';

  @override
  String get proPageBackup => 'Copia de seguridad automática con Google Drive™';

  @override
  String get proPageCsv => 'Exportar registro a hoja de cálculo (CSV)';

  @override
  String get proPageAtmosphere => 'Obtener datos de atmósfera, clima y mareas';

  @override
  String get proPageReports => 'Crea informes y filtros personalizados';

  @override
  String get proPageCustomFields => 'Crear campos de entrada personalizados';

  @override
  String get proPageGpsTrails => 'Crea y rastrea senderos GPS en tiempo real';

  @override
  String get proPageCopyCatch => 'Copiar capturas';

  @override
  String get proPageSpeciesCounter =>
      'Contador de especies capturadas en tiempo real';

  @override
  String get periodDawn => 'Amanecer';

  @override
  String get periodMorning => 'Mañana';

  @override
  String get periodMidday => 'Mediodía';

  @override
  String get periodAfternoon => 'Tarde';

  @override
  String get periodEvening => 'Tarde';

  @override
  String get periodDusk => 'Anochecer';

  @override
  String get periodNight => 'Noche';

  @override
  String get periodPickerAll => 'Todas las horas del día';

  @override
  String get seasonWinter => 'Invierno';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verano';

  @override
  String get seasonAutumn => 'Otoño';

  @override
  String get seasonPickerAll => 'Todas las estaciones';

  @override
  String get measurementSystemImperial => 'Imperial';

  @override
  String get measurementSystemImperialDecimal => 'Decimal imperial';

  @override
  String get measurementSystemMetric => 'Métrico';

  @override
  String get numberBoundaryAny => 'Cualquiera';

  @override
  String get numberBoundaryLessThan => 'Menor que (<)';

  @override
  String get numberBoundaryLessThanOrEqualTo => 'Menor o igual a (≤)';

  @override
  String get numberBoundaryEqualTo => 'Igual a (=)';

  @override
  String get numberBoundaryGreaterThan => 'Mayor que (>)';

  @override
  String get numberBoundaryGreaterThanOrEqualTo => 'Mayor o igual a (≥)';

  @override
  String get numberBoundaryRange => 'Rango';

  @override
  String numberBoundaryLessThanValue(String value) {
    return '< $value';
  }

  @override
  String numberBoundaryLessThanOrEqualToValue(String value) {
    return '≤ $value';
  }

  @override
  String numberBoundaryEqualToValue(String value) {
    return '= $value';
  }

  @override
  String numberBoundaryGreaterThanValue(String value) {
    return '> $value';
  }

  @override
  String numberBoundaryGreaterThanOrEqualToValue(String value) {
    return '≥ $value';
  }

  @override
  String numberBoundaryRangeValue(String from, String to) {
    return '$from - $to';
  }

  @override
  String get unitFeet => 'ft';

  @override
  String get unitInches => 'in';

  @override
  String get unitPounds => 'lbs';

  @override
  String get unitOunces => 'oz';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitMeters => 'm';

  @override
  String get unitCentimeters => 'cm';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitMilesPerHour => 'mph';

  @override
  String get unitKilometersPerHour => 'km/h';

  @override
  String get unitMillibars => 'MB';

  @override
  String get unitPoundsPerSquareInch => 'psi';

  @override
  String get unitPercent => '%';

  @override
  String get unitInchOfMercury => 'inHg';

  @override
  String get unitMiles => 'mi';

  @override
  String get unitKilometers => 'km';

  @override
  String get unitX => 'X';

  @override
  String get unitAught => 'O';

  @override
  String get unitPoundTest => 'lb test';

  @override
  String get unitHashtag => '#';

  @override
  String get unitMetersPerSecond => 'm/s';

  @override
  String unitConvertToValue(String unit) {
    return 'Convertir a $unit';
  }

  @override
  String get numberFilterInputFrom => 'De';

  @override
  String get numberFilterInputTo => 'A';

  @override
  String get numberFilterInputValue => 'Valor';

  @override
  String get filterTitleWaterTemperature => 'Filtro de temperatura del agua';

  @override
  String get filterTitleWaterDepth => 'Filtro de profundidad del agua';

  @override
  String get filterTitleLength => 'Filtro de longitud';

  @override
  String get filterTitleWeight => 'Filtro de peso';

  @override
  String get filterTitleQuantity => 'Filtro de cantidad';

  @override
  String get filterTitleAirTemperature => 'Filtro de temperatura del aire';

  @override
  String get filterTitleAirPressure => 'Filtro de presión atmosférica';

  @override
  String get filterTitleAirHumidity => 'Filtro de humedad del aire';

  @override
  String get filterTitleAirVisibility => 'Filtro de visibilidad del aire';

  @override
  String get filterTitleWindSpeed => 'Filtro de velocidad del viento';

  @override
  String filterValueWaterTemperature(String value) {
    return 'Temperatura del agua: $value';
  }

  @override
  String filterValueWaterDepth(String value) {
    return 'Profundidad del agua: $value';
  }

  @override
  String filterValueLength(String value) {
    return 'Longitud: $value';
  }

  @override
  String filterValueWeight(String value) {
    return 'Peso: $value';
  }

  @override
  String filterValueQuantity(String value) {
    return 'Cantidad: $value';
  }

  @override
  String filterValueAirTemperature(String value) {
    return 'Temperatura del aire: $value';
  }

  @override
  String filterValueAirPressure(String value) {
    return 'Presión atmosférica: $value';
  }

  @override
  String filterValueAirHumidity(String value) {
    return 'Humedad del aire: $value%';
  }

  @override
  String filterValueAirVisibility(String value) {
    return 'Visibilidad del aire: $value';
  }

  @override
  String filterValueWindSpeed(String value) {
    return 'Velocidad del viento: $value';
  }

  @override
  String filterPageInvalidEndValue(String value) {
    return 'Debe ser mayor que $value';
  }

  @override
  String get moonPhaseNew => 'Nuevo';

  @override
  String get moonPhaseWaxingCrescent => 'Creciente waxing';

  @override
  String get moonPhaseFirstQuarter => '1er cuarto';

  @override
  String get moonPhaseWaxingGibbous => 'Gibosa waxing';

  @override
  String get moonPhaseFull => 'Completo';

  @override
  String get moonPhaseWaningGibbous => 'Gibosa menguante';

  @override
  String get moonPhaseLastQuarter => 'Último cuarto';

  @override
  String get moonPhaseWaningCrescent => 'Creciente menguante';

  @override
  String moonPhaseChip(String value) {
    return '$value Luna';
  }

  @override
  String get atmosphereInputTemperature => 'Temperatura';

  @override
  String get atmosphereInputAirTemperature => 'Temperatura del aire';

  @override
  String get atmosphereInputSkyConditions => 'Condiciones del cielo';

  @override
  String get atmosphereInputNoSkyConditions => 'Sin condiciones del cielo';

  @override
  String get atmosphereInputWindSpeed => 'Velocidad del viento';

  @override
  String get atmosphereInputWind => 'Viento';

  @override
  String get atmosphereInputWindDirection => 'Dirección del viento';

  @override
  String get atmosphereInputPressure => 'Presión';

  @override
  String get atmosphereInputAtmosphericPressure => 'Presión atmosférica';

  @override
  String get atmosphereInputHumidity => 'Humedad';

  @override
  String get atmosphereInputAirHumidity => 'Humedad del aire';

  @override
  String get atmosphereInputVisibility => 'Visibilidad';

  @override
  String get atmosphereInputAirVisibility => 'Visibilidad del Aire';

  @override
  String get atmosphereInputMoon => 'Luna';

  @override
  String get atmosphereInputMoonPhase => 'Fase lunar';

  @override
  String get atmosphereInputSunrise => 'Amanecer';

  @override
  String get atmosphereInputTimeOfSunrise => 'Hora del amanecer';

  @override
  String get atmosphereInputSunset => 'Atardecer';

  @override
  String get atmosphereInputTimeOfSunset => 'Hora del atardecer';

  @override
  String get directionNorth => 'N';

  @override
  String get directionNorthEast => 'NE';

  @override
  String get directionEast => 'E';

  @override
  String get directionSouthEast => 'SE';

  @override
  String get directionSouth => 'S';

  @override
  String get directionSouthWest => 'SO';

  @override
  String get directionWest => 'O';

  @override
  String get directionNorthWest => 'NO';

  @override
  String directionWindChip(String value) {
    return 'Viento: $value';
  }

  @override
  String get skyConditionSnow => 'Nieve';

  @override
  String get skyConditionDrizzle => 'Llovizna';

  @override
  String get skyConditionDust => 'Polvo';

  @override
  String get skyConditionFog => 'Niebla';

  @override
  String get skyConditionRain => 'Lluvia';

  @override
  String get skyConditionTornado => 'Tornado';

  @override
  String get skyConditionHail => 'Granizo';

  @override
  String get skyConditionIce => 'Hielo';

  @override
  String get skyConditionStorm => 'Tormenta';

  @override
  String get skyConditionMist => 'Bruma';

  @override
  String get skyConditionSmoke => 'Humo';

  @override
  String get skyConditionOvercast => 'Nublado';

  @override
  String get skyConditionCloudy => 'Nublado';

  @override
  String get skyConditionClear => 'Limpiar';

  @override
  String get skyConditionSunny => 'Soleado';

  @override
  String get pickerTitleBait => 'Seleccionar cebo';

  @override
  String get pickerTitleBaits => 'Seleccionar cebos';

  @override
  String get pickerTitleBaitCategory => 'Seleccionar categoría de cebo';

  @override
  String get pickerTitleAngler => 'Seleccionar pescador';

  @override
  String get pickerTitleAnglers => 'Seleccionar pescadores';

  @override
  String get pickerTitleFishingMethods => 'Seleccionar métodos de pesca';

  @override
  String get pickerTitleWaterClarity => 'Seleccionar claridad del agua';

  @override
  String get pickerTitleWaterClarities => 'Seleccionar claridades del agua';

  @override
  String get pickerTitleDateRange => 'Seleccionar rango de fechas';

  @override
  String get pickerTitleFields => 'Seleccionar campos';

  @override
  String get pickerTitleReport => 'Seleccionar informe';

  @override
  String get pickerTitleSpecies => 'Seleccionar especies';

  @override
  String get pickerTitleFishingSpot => 'Seleccionar lugar de pesca';

  @override
  String get pickerTitleFishingSpots => 'Seleccionar lugares de pesca';

  @override
  String get pickerTitleTimeOfDay => 'Seleccionar hora del día';

  @override
  String get pickerTitleTimesOfDay => 'Seleccionar horas del día';

  @override
  String get pickerTitleSeason => 'Seleccionar temporada';

  @override
  String get pickerTitleSeasons => 'Seleccionar temporadas';

  @override
  String get pickerTitleMoonPhase => 'Seleccionar fase lunar';

  @override
  String get pickerTitleMoonPhases => 'Seleccionar fases lunares';

  @override
  String get pickerTitleSkyCondition => 'Seleccionar condición del cielo';

  @override
  String get pickerTitleSkyConditions => 'Seleccionar condiciones del cielo';

  @override
  String get pickerTitleWindDirection => 'Seleccionar dirección del viento';

  @override
  String get pickerTitleWindDirections => 'Seleccionar direcciones del viento';

  @override
  String get pickerTitleTide => 'Seleccionar marea';

  @override
  String get pickerTitleTides => 'Seleccionar mareas';

  @override
  String get pickerTitleBodyOfWater => 'Seleccionar cuerpo de agua';

  @override
  String get pickerTitleBodiesOfWater => 'Seleccionar cuerpos de agua';

  @override
  String get pickerTitleCatches => 'Seleccionar capturas';

  @override
  String get pickerTitleTimeZone => 'Seleccionar zona horaria';

  @override
  String get pickerTitleGpsTrails => 'Seleccionar rutas GPS';

  @override
  String get pickerTitleGear => 'Seleccionar equipo';

  @override
  String get pickerTitleRodAction => 'Seleccionar acción';

  @override
  String get pickerTitleRodPower => 'Seleccionar potencia';

  @override
  String get pickerTitleTrip => 'Seleccionar viaje';

  @override
  String get keywordsTemperatureMetric => 'temperatura en grados celsius c';

  @override
  String get keywordsTemperatureImperial =>
      'temperatura en grados fahrenheit f';

  @override
  String get keywordsSpeedImperial => 'millas por hora velocidad del viento';

  @override
  String get keywordsAirPressureMetric => 'presión atmosférica en milibares';

  @override
  String get keywordsAirPressureImperial =>
      'presión atmosférica en libras por pulgada cuadrada';

  @override
  String get keywordsAirHumidity => 'porcentaje de humedad';

  @override
  String get keywordsAirVisibilityMetric => 'kilómetros de visibilidad';

  @override
  String get keywordsAirVisibilityImperial => 'millas de visibilidad';

  @override
  String get keywordsPercent => 'porcentaje';

  @override
  String get keywordsInchOfMercury =>
      'pulgada de mercurio, presión atmosférica barométrica';

  @override
  String get keywordsSunrise => 'amanecer';

  @override
  String get keywordsSunset => 'atardecer';

  @override
  String get keywordsCatchAndRelease => 'mantenido';

  @override
  String get keywordsFavorite => 'Favorito';

  @override
  String get keywordsDepthMetric => 'profundidad en metros';

  @override
  String get keywordsDepthImperial => 'profundidad en pies y pulgadas';

  @override
  String get keywordsLengthMetric => 'longitud en centímetros cm';

  @override
  String get keywordsLengthImperial => 'longitud en pulgadas \" in';

  @override
  String get keywordsWeightMetric => 'peso en kilos kg';

  @override
  String get keywordsWeightImperial => 'peso en libras y onzas lbs oz';

  @override
  String get keywordsX => 'x';

  @override
  String get keywordsAught => 'cero';

  @override
  String get keywordsPoundTest => 'prueba de libra';

  @override
  String get keywordsHashtag => '#';

  @override
  String get keywordsMetersPerSecond => 'metros por segundo m/s';

  @override
  String get keywordsNorth => 'n norte';

  @override
  String get keywordsNorthEast => 'ne noreste';

  @override
  String get keywordsEast => 'e este';

  @override
  String get keywordsSouthEast => 'se sureste';

  @override
  String get keywordsSouth => 's sur';

  @override
  String get keywordsSouthWest => 'sw suroeste';

  @override
  String get keywordsWest => 'w oeste';

  @override
  String get keywordsNorthWest => 'nw noroeste';

  @override
  String get keywordsWindDirection => 'dirección del viento';

  @override
  String get keywordsMoon => 'fase lunar';

  @override
  String get tideInputTitle => 'Marea';

  @override
  String tideInputLowTimeValue(String value) {
    return 'Baja: $value';
  }

  @override
  String tideInputHighTimeValue(String value) {
    return 'Alta: $value';
  }

  @override
  String tideInputDatumValue(String value) {
    return 'Datum: $value';
  }

  @override
  String get tideInputFirstLowTimeLabel => 'Hora de la primera marea baja';

  @override
  String get tideInputFirstHighTimeLabel => 'Hora de la primera marea alta';

  @override
  String get tideInputSecondLowTimeLabel => 'Hora de la segunda marea baja';

  @override
  String get tideInputSecondHighTimeLabel => 'Hora de la segunda marea alta';

  @override
  String get tideTypeLow => 'Baja';

  @override
  String get tideTypeOutgoing => 'Saliente';

  @override
  String get tideTypeHigh => 'Alta';

  @override
  String get tideTypeSlack => 'Muerto';

  @override
  String get tideTypeIncoming => 'Entrante';

  @override
  String get tideLow => 'Marea baja';

  @override
  String get tideOutgoing => 'Marea saliente';

  @override
  String get tideHigh => 'Marea alta';

  @override
  String get tideSlack => 'Marea muerta';

  @override
  String get tideIncoming => 'Marea entrante';

  @override
  String tideTimeAndHeight(String height, String time) {
    return '$height a la $time';
  }

  @override
  String get saveBaitVariantPageTitle => 'Editar variante de cebo';

  @override
  String get saveBaitVariantPageEditTitle => 'Nueva variante de cebo';

  @override
  String get saveBaitVariantPageModelNumber => 'Número de modelo';

  @override
  String get saveBaitVariantPageSize => 'Tamaño';

  @override
  String get saveBaitVariantPageMinDiveDepth => 'Profundidad mínima de buceo';

  @override
  String get saveBaitVariantPageMaxDiveDepth => 'Profundidad máxima de buceo';

  @override
  String get saveBaitVariantPageDescription => 'Descripción';

  @override
  String get baitVariantPageVariantLabel => 'Variante de';

  @override
  String get baitVariantPageModel => 'Número de modelo';

  @override
  String get baitVariantPageSize => 'Tamaño';

  @override
  String get baitVariantPageDiveDepth => 'Profundidad de inmersión';

  @override
  String get baitTypeArtificial => 'Artificial';

  @override
  String get baitTypeReal => 'Real';

  @override
  String get baitTypeLive => 'Activo';

  @override
  String bodyOfWaterListPageDeleteMessage(String bodyOfWater, int numOfSpots) {
    return '$bodyOfWater está asociado con $numOfSpots lugares de pesca; ¿estás seguro de que quieres eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String bodyOfWaterListPageDeleteMessageSingular(String bodyOfWater) {
    return '$bodyOfWater está asociado con 1 lugar de pesca; ¿estás seguro de que quieres eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String bodyOfWaterListPageTitle(int numOfBodiesOfWater) {
    return 'Cuerpos de agua ($numOfBodiesOfWater)';
  }

  @override
  String get bodyOfWaterListPageSearchHint => 'Buscar cuerpos de agua';

  @override
  String get bodyOfWaterListPageEmptyListTitle => 'Sin cuerpos de agua';

  @override
  String get bodyOfWaterListPageEmptyListDescription =>
      'Aún no has añadido cuerpos de agua. Toca el botón %s para comenzar.';

  @override
  String get bodiesOfWaterSummaryEmpty =>
      'Cuando se añadan cuerpos de agua a tu registro, aquí se mostrará un resumen de sus capturas.';

  @override
  String get saveBodyOfWaterPageNewTitle => 'Nuevo cuerpo de agua';

  @override
  String get saveBodyOfWaterPageEditTitle => 'Editar cuerpo de agua';

  @override
  String get saveBodyOfWaterPageExistsMessage => 'El cuerpo de agua ya existe';

  @override
  String get mapAttributionTitleApple => 'SDK de Mapbox Maps para iOS';

  @override
  String get mapAttributionTitleAndroid => 'SDK de Mapbox Maps para Android';

  @override
  String get mapAttributionMapbox => '© Mapbox';

  @override
  String get mapAttributionOpenStreetMap => '© OpenStreetMap';

  @override
  String get mapAttributionImproveThisMap => 'Mejorar este mapa';

  @override
  String get mapAttributionMaxar => '© Maxar';

  @override
  String get mapAttributionTelemetryTitle => 'Telemetría de Mapbox';

  @override
  String get mapAttributionTelemetryDescription =>
      'Ayuda a mejorar los mapas de OpenStreetMap y Mapbox contribuyendo con datos de uso anónimos.';

  @override
  String get entityNameAnglers => 'Pescadores';

  @override
  String get entityNameAngler => 'Pescador';

  @override
  String get entityNameBaitCategories => 'Categorías de Cebo';

  @override
  String get entityNameBaitCategory => 'Categoría de Cebo';

  @override
  String get entityNameBaits => 'Cebos';

  @override
  String get entityNameBait => 'Cebo';

  @override
  String get entityNameBodiesOfWater => 'Cuerpos de Agua';

  @override
  String get entityNameBodyOfWater => 'Cuerpo de Agua';

  @override
  String get entityNameCatch => 'Captura';

  @override
  String get entityNameCatches => 'Capturas';

  @override
  String get entityNameCustomFields => 'Campos Personalizados';

  @override
  String get entityNameCustomField => 'Campo personalizado';

  @override
  String get entityNameFishingMethods => 'Métodos de Pesca';

  @override
  String get entityNameFishingMethod => 'Método de Pesca';

  @override
  String get entityNameGear => 'Equipo';

  @override
  String get entityNameGpsTrails => 'Rutas GPS';

  @override
  String get entityNameGpsTrail => 'Ruta GPS';

  @override
  String get entityNameSpecies => 'Especies';

  @override
  String get entityNameTrip => 'Viaje';

  @override
  String get entityNameTrips => 'Viajes';

  @override
  String get entityNameWaterClarities => 'Claridades del Agua';

  @override
  String get entityNameWaterClarity => 'Claridad del Agua';

  @override
  String get tripSummaryTitle => 'Resumen del viaje';

  @override
  String get tripSummaryTotalTripTime => 'Tiempo total de viaje';

  @override
  String get tripSummaryLongestTrip => 'Viaje más largo';

  @override
  String get tripSummarySinceLastTrip => 'Desde el último viaje';

  @override
  String get tripSummaryAverageTripTime => 'Tiempo promedio de viaje';

  @override
  String get tripSummaryAverageTimeBetweenTrips => 'Entre viajes';

  @override
  String get tripSummaryAverageTimeBetweenCatches => 'Entre capturas';

  @override
  String get tripSummaryCatchesPerTrip => 'Capturas por viaje';

  @override
  String get tripSummaryCatchesPerHour => 'Capturas por hora';

  @override
  String get tripSummaryWeightPerTrip => 'Peso por viaje';

  @override
  String get tripSummaryBestWeight => 'Mejor peso';

  @override
  String get tripSummaryLengthPerTrip => 'Longitud por viaje';

  @override
  String get tripSummaryBestLength => 'Mejor longitud';

  @override
  String get backupPageTitle => 'Copia de seguridad';

  @override
  String get backupPageDescription =>
      'Tus datos se copian a una carpeta privada en tu Google Drive™ y no se comparten públicamente.\n\nEl proceso de copia de seguridad puede tardar varios minutos.';

  @override
  String get backupPageAction => 'Hacer copia de seguridad ahora';

  @override
  String get backupPageErrorTitle => 'Error de copia de seguridad';

  @override
  String get backupPageAutoTitle => 'Copia de seguridad automática';

  @override
  String get backupPageLastBackupLabel => 'Última copia de seguridad';

  @override
  String get backupPageLastBackupNever => 'Nunca';

  @override
  String get restorePageTitle => 'Restaurar';

  @override
  String get restorePageDescription =>
      'Restaurar datos reemplaza completamente su registro existente con los datos almacenados en Google Drive™. Si no hay datos, su registro permanece sin cambios.\n\nEl proceso de restauración puede tardar varios minutos.';

  @override
  String get restorePageAction => 'Restaurar ahora';

  @override
  String get restorePageErrorTitle => 'Error de restauración';

  @override
  String get backupRestoreAuthError =>
      'Error de autenticación, por favor intenta de nuevo más tarde.';

  @override
  String get backupRestoreAutoSignedOutError =>
      'La copia de seguridad automática falló debido a un tiempo de espera de autenticación. Por favor, inicia sesión nuevamente.';

  @override
  String get backupRestoreAutoNetworkError =>
      'La copia de seguridad automática falló debido a un problema de conectividad de red. Por favor, haz una copia de seguridad manual o espera el próximo intento de copia de seguridad automática.';

  @override
  String get backupRestoreCreateFolderError =>
      'Error al crear la carpeta de respaldo, por favor intenta de nuevo más tarde.';

  @override
  String get backupRestoreFolderNotFound =>
      'Carpeta de respaldo no encontrada. Debes respaldar tus datos antes de que puedan ser restaurados.';

  @override
  String get backupRestoreApiRequestError =>
      'La red puede haber sido interrumpida. Verifica tu conexión a internet y vuelve a intentarlo. Si el problema persiste, por favor envía un informe a Anglers\' Log para su investigación.';

  @override
  String get backupRestoreDatabaseNotFound =>
      'Archivo de datos de respaldo no encontrado. Debes respaldar tus datos antes de que puedan ser restaurados.';

  @override
  String get backupRestoreAccessDenied =>
      'Anglers\' Log no tiene permiso para hacer una copia de seguridad de tus datos. Por favor, cierra sesión y vuelve a iniciar sesión, asegurándote de que la casilla \"Ver, crear y eliminar sus propios datos de configuración en tu Google Drive™.\" esté marcada, y vuelve a intentarlo.';

  @override
  String get backupRestoreStorageFull =>
      'Tu almacenamiento de Google Drive™ está lleno. Por favor libera algo de espacio e intenta de nuevo.';

  @override
  String get backupRestoreAuthenticating => 'Autenticando...';

  @override
  String get backupRestoreFetchingFiles => 'Obteniendo datos...';

  @override
  String get backupRestoreCreatingFolder => 'Creando carpeta de respaldo...';

  @override
  String get backupRestoreBackingUpDatabase =>
      'Haciendo copia de seguridad de la base de datos...';

  @override
  String backupRestoreBackingUpImages(String percent) {
    return 'Haciendo copia de seguridad de imágenes$percent...';
  }

  @override
  String get backupRestoreDownloadingDatabase => 'Descargando base de datos...';

  @override
  String backupRestoreDownloadingImages(String percent) {
    return 'Descargando imágenes$percent...';
  }

  @override
  String get backupRestoreReloadingData => 'Recargando datos...';

  @override
  String get backupRestoreSuccess => '¡Éxito!';

  @override
  String get cloudAuthSignOut => 'Cerrar sesión';

  @override
  String get cloudAuthSignedInAs => 'Conectado como';

  @override
  String get cloudAuthSignInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get cloudAuthDescription =>
      'Para continuar, debes iniciar sesión en tu cuenta de Google. Los datos se guardan en una carpeta privada de Google Drive™ y solo pueden ser accedidos por Anglers\' Log.';

  @override
  String get cloudAuthError =>
      'Error al iniciar sesión, por favor intenta de nuevo más tarde.';

  @override
  String get cloudAuthNetworkError =>
      'Hubo un error de red al iniciar sesión. Por favor asegúrate de estar conectado a internet e intenta de nuevo.';

  @override
  String get asyncFeedbackSendReport => 'Enviar informe';

  @override
  String get addAnythingTitle => 'Agregar nuevo';

  @override
  String get proBlurUpgradeButton => 'Actualizar';

  @override
  String get aboutPageVersion => 'Versión';

  @override
  String get aboutPageEula => 'Términos de Uso (EULA)';

  @override
  String get aboutPagePrivacy => 'Política de privacidad';

  @override
  String get aboutPageWorldTides => 'Política de Privacidad de WorldTides™';

  @override
  String get aboutPageWorldTidePrivacy =>
      'Datos de mareas recuperados de www.worldtides.info. Copyright © 2014-2023 Brainware LLC.\n\nLicenciado para el uso de coordenadas espaciales individuales por un usuario final.\n\nNO SE HACEN GARANTÍAS SOBRE LA CORRECCIÓN DE ESTOS DATOS DE MAREA.\nNo puede usar estos datos si alguien o algo podría resultar dañado como resultado de su uso (por ejemplo, para fines de navegación).\n\nLos datos de mareas se obtienen de varias fuentes y están cubiertos en parte o en su totalidad por varios derechos de autor. Para más detalles, consulte: http://www.worldtides.info/copyright';

  @override
  String get fishingSpotDetailsAddDetails => 'Agregar detalles';

  @override
  String fishingSpotDetailsCatches(int numOfCatches) {
    return '$numOfCatches capturas';
  }

  @override
  String get fishingSpotDetailsCatch => '1 captura';

  @override
  String get timeZoneInputLabel => 'Zona horaria';

  @override
  String get timeZoneInputDescription =>
      'Se establece en su zona horaria actual.';

  @override
  String get timeZoneInputSearchHint => 'Buscar zonas horarias';

  @override
  String get pollsPageTitle => 'Encuestas de funciones';

  @override
  String get pollsPageDescription =>
      'Vota para determinar qué características se agregarán en la próxima versión de Anglers\' Log.';

  @override
  String get pollsPageNoPollsTitle => 'Sin encuestas';

  @override
  String get pollsPageNoPollsDescription =>
      'Actualmente no hay encuestas de funciones. Si deseas solicitar una función, ¡por favor envíanos tus comentarios!';

  @override
  String get pollsPageSendFeedback => 'Enviar comentarios';

  @override
  String get pollsPageNextFreeFeature => 'Próxima característica gratuita';

  @override
  String get pollsPageNextProFeature => 'Próxima característica pro';

  @override
  String get pollsPageThankYouFree =>
      '¡Gracias por votar en la encuesta de funciones gratuitas!';

  @override
  String get pollsPageThankYouPro =>
      '¡Gracias por votar en la encuesta de funciones pro!';

  @override
  String get pollsPageError =>
      'Hubo un error al emitir tu voto. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get pollsPageComingSoonFree =>
      'Próximamente para usuarios gratuitos (según votación)';

  @override
  String get pollsPageComingSoonPro =>
      'Próximamente para usuarios pro (según votación)';

  @override
  String get permissionLocationTitle => 'Acceso a la ubicación';

  @override
  String get permissionCurrentLocationDescription =>
      'Para mostrar tu ubicación actual, debes otorgar a Anglers\' Log acceso para leer la ubicación de tu dispositivo. Para hacerlo, abre la configuración de tu dispositivo.';

  @override
  String get permissionGpsTrailDescription =>
      'Para crear un rastro GPS preciso, Anglers\' Log debe poder acceder a la ubicación de tu dispositivo en todo momento mientras el seguimiento esté activo. Para otorgar el permiso requerido, abre la configuración de tu dispositivo.';

  @override
  String get permissionOpenSettings => 'Abrir configuración';

  @override
  String get permissionLocationNotificationDescription =>
      'El rastro GPS está activo';

  @override
  String get calendarPageTitle => 'Calendario';

  @override
  String get calendarPageTripLabel => 'Viaje';

  @override
  String gpsTrailListPageTitle(int numOfTrails) {
    return 'Rutas GPS ($numOfTrails)';
  }

  @override
  String get gpsTrailListPageSearchHint => 'Buscar rutas GPS';

  @override
  String get gpsTrailListPageEmptyListTitle => 'Sin rutas GPS';

  @override
  String get gpsTrailListPageEmptyListDescription =>
      'Para iniciar una ruta GPS, toca el botón %s en el mapa.';

  @override
  String get gpsTrailListPageDeleteMessageSingular =>
      'Esta ruta GPS está asociada con 1 viaje; ¿estás seguro de que deseas eliminarla? Esto no se puede deshacer.';

  @override
  String gpsTrailListPageDeleteMessage(int numOfTrips) {
    return 'Esta ruta GPS está asociada con $numOfTrips viajes; ¿estás seguro de que deseas eliminarla? Esto no se puede deshacer.';
  }

  @override
  String gpsTrailListPageNumberOfPoints(int numOfPoints) {
    return '$numOfPoints puntos';
  }

  @override
  String get gpsTrailListPageInProgress => 'En progreso';

  @override
  String get saveGpsTrailPageEditTitle => 'Editar ruta GPS';

  @override
  String get tideFetcherErrorNoLocationFound =>
      'La ubicación de fetch está demasiado lejos de la costa para determinar la información de las mareas.';

  @override
  String get csvPageTitle => 'Exportar CSV';

  @override
  String get csvPageAction => 'Exportar';

  @override
  String get csvPageDescription =>
      'Se creará un archivo CSV separado para cada selección a continuación.';

  @override
  String get csvPageImportWarning =>
      'Al importar en software de hojas de cálculo, el origen del archivo de los archivos CSV exportados es Unicode (UTF-8) y el delimitador es una coma.';

  @override
  String get csvPageBackupWarning =>
      'Los archivos CSV no son copias de seguridad y no se pueden importar a Anglers\' Log. En su lugar, utiliza los botones de Copia de seguridad y Restaurar en la página Más.';

  @override
  String get csvPageSuccess => '¡Éxito!';

  @override
  String get csvPageMustSelect =>
      'Por favor, selecciona al menos una opción de exportación arriba.';

  @override
  String get tripFieldStartDate => 'Fecha de inicio';

  @override
  String get tripFieldEndDate => 'Fecha de finalización';

  @override
  String get tripFieldStartTime => 'Hora de inicio';

  @override
  String get tripFieldEndTime => 'Hora de finalización';

  @override
  String get tripFieldPhotos => 'Fotos';

  @override
  String gearListPageTitle(int numOfGear) {
    return 'Equipo ($numOfGear)';
  }

  @override
  String gearListPageDeleteMessage(String gear, int numOfCatches) {
    return '$gear está asociado con $numOfCatches capturas; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String gearListPageDeleteMessageSingular(String gear) {
    return '$gear está asociado con 1 captura; ¿estás seguro de que deseas eliminarlo? Esto no se puede deshacer.';
  }

  @override
  String get gearListPageSearchHint => 'Buscar equipo';

  @override
  String get gearListPageEmptyListTitle => 'Sin equipo';

  @override
  String get gearListPageEmptyListDescription =>
      'Aún no has agregado ningún equipo. Toca el botón %s para comenzar.';

  @override
  String get gearSummaryEmpty =>
      'Cuando se agregue equipo a tu registro, aquí se mostrará un resumen de sus capturas.';

  @override
  String get gearActionXFast => 'X-Rápido';

  @override
  String get gearActionFast => 'Rápido';

  @override
  String get gearActionModerateFast => 'Moderado rápido';

  @override
  String get gearActionModerate => 'Moderado';

  @override
  String get gearActionSlow => 'Lento';

  @override
  String get gearPowerUltralight => 'Ultraligero';

  @override
  String get gearPowerLight => 'Ligero';

  @override
  String get gearPowerMediumLight => 'Luz media';

  @override
  String get gearPowerMedium => 'Media';

  @override
  String get gearPowerMediumHeavy => 'Medio pesado';

  @override
  String get gearPowerHeavy => 'Pesado';

  @override
  String get gearPowerXHeavy => 'X-Pesado';

  @override
  String get gearPowerXxHeavy => 'XX-Pesado';

  @override
  String get gearPowerXxxHeavy => 'XXX-Pesado';

  @override
  String get gearFieldImage => 'Foto';

  @override
  String get gearFieldRodMakeModel => 'Marca y modelo de la caña';

  @override
  String get gearFieldRodSerialNumber => 'Número de serie de la caña';

  @override
  String get gearFieldRodLength => 'Longitud de la caña';

  @override
  String get gearFieldRodAction => 'Acción de la caña';

  @override
  String get gearFieldRodPower => 'Potencia de la caña';

  @override
  String get gearFieldReelMakeModel => 'Marca y modelo del carrete';

  @override
  String get gearFieldReelSerialNumber => 'Número de serie del carrete';

  @override
  String get gearFieldReelSize => 'Tamaño del carrete';

  @override
  String get gearFieldLineMakeModel => 'Marca y modelo de la línea';

  @override
  String get gearFieldLineRating => 'Clasificación de la línea';

  @override
  String get gearFieldLineColor => 'Color de la línea';

  @override
  String get gearFieldLeaderLength => 'Longitud del líder';

  @override
  String get gearFieldLeaderRating => 'Clasificación del líder';

  @override
  String get gearFieldTippetLength => 'Longitud del tippet';

  @override
  String get gearFieldTippetRating => 'Clasificación del tippet';

  @override
  String get gearFieldHookMakeModel => 'Marca y modelo del anzuelo';

  @override
  String get gearFieldHookSize => 'Tamaño del anzuelo';

  @override
  String get saveGearPageEditTitle => 'Editar equipo';

  @override
  String get saveGearPageNewTitle => 'Nuevo equipo';

  @override
  String get saveGearPageNameExists => 'El nombre del equipo ya existe';

  @override
  String gearPageSerialNumber(String serialNo) {
    return 'Número de serie: $serialNo';
  }

  @override
  String gearPageSize(String size) {
    return 'Tamaño: $size';
  }

  @override
  String gearPageLeader(String leader) {
    return 'Líder: $leader';
  }

  @override
  String gearPageTippet(String tippet) {
    return 'Tippet: $tippet';
  }

  @override
  String get notificationPermissionPageTitle => 'Notificar';

  @override
  String get notificationPermissionPageDesc =>
      'Permitir que Anglers\' Log te notifique si una copia de seguridad de datos falla por cualquier motivo, incluyendo la necesidad de re-autenticación.';

  @override
  String get notificationErrorBackupTitle => 'Error de copia de seguridad';

  @override
  String get notificationErrorBackupBody =>
      '¡Oh no! Algo salió mal al hacer una copia de seguridad de tus datos. Toca aquí para más detalles.';

  @override
  String get notificationChannelNameBackup => 'Copia de seguridad de datos';

  @override
  String get speciesCounterPageTitle => 'Contador de especies';

  @override
  String get speciesCounterPageReset => 'Restablecer';

  @override
  String get speciesCounterPageCreateTrip => 'Crear viaje';

  @override
  String get speciesCounterPageAddToTrip => 'Agregar viaje';

  @override
  String get speciesCounterPageSelect => 'Seleccionar especies';

  @override
  String speciesCounterPageTripUpdated(String trip) {
    return 'Los conteos de especies se agregaron a $trip.';
  }

  @override
  String get speciesCounterPageGeneralTripName => 'Viaje';

  @override
  String get locationDataFetcherErrorNoPermission =>
      'Se requiere permiso para obtener datos. Por favor, concede a Anglers\' Log el permiso de ubicación y vuelve a intentarlo.';

  @override
  String get locationDataFetcherPermissionError =>
      'Hubo un error al solicitar el permiso de ubicación. El equipo de Anglers\' Log ha sido notificado y nos disculpamos por las molestias.';

  @override
  String get landingPageInitError =>
      '¡Oh no! Algo salió mal durante la inicialización. El equipo de Anglers\' Log ha sido notificado y nos disculpamos por las molestias.';

  @override
  String get changeLogPageTitle => 'Novedades';

  @override
  String get changeLogPagePreviousVersion => 'Tu versión anterior';

  @override
  String get changeLog_2022_1 => 'Una reescritura completa de Anglers\' Log';

  @override
  String get changeLog_2022_2 => 'Una apariencia y sensación fresca y moderna';

  @override
  String get changeLog_2022_3 =>
      'Una función de estadísticas completamente nueva, extensa y detallada';

  @override
  String get changeLog_2022_4 =>
      'Datos detallados de atmósfera y clima, incluyendo fases lunares y mareas';

  @override
  String get changeLog_2022_5 =>
      'Obtén más de Anglers\' Log suscribiéndote a Anglers\' Log Pro';

  @override
  String get changeLog_2022_6 =>
      'Además de muchas más funciones solicitadas por los usuarios';

  @override
  String get changeLog_210_1 =>
      'En Más > Encuestas de características, ahora puedes votar sobre qué características deseas ver a continuación';

  @override
  String get changeLog_210_2 =>
      'Se solucionó el problema donde las esquinas de las fotos de mejor marca personal no estaban redondeadas';

  @override
  String get changeLog_210_3 =>
      'Se solucionó el problema donde los valores de cantidad de captura no se contaban en la página de estadísticas';

  @override
  String get changeLog_210_4 =>
      'La distancia de selección automática de lugares de pesca ahora es configurable en Configuración';

  @override
  String get changeLog_212_1 =>
      'Se solucionó un bloqueo al importar datos heredados';

  @override
  String get changeLog_212_2 =>
      'Se solucionó un bloqueo al editar informes de comparación';

  @override
  String get changeLog_212_3 =>
      'Se solucionó el problema del mapa que aparecía para algunos usuarios después de regresar al primer plano';

  @override
  String get changeLog_212_4 =>
      'Se eliminó el límite de caracteres en el campo de entrada de notas';

  @override
  String get changeLog_213_1 =>
      'Se solucionó un problema donde la restauración de datos a veces fallaba';

  @override
  String get changeLog_213_2 =>
      'Se solucionó un fallo durante la migración de datos heredados';

  @override
  String get changeLog_213_3 => 'Mejoras en el rendimiento';

  @override
  String get changeLog_213_4 => 'Los usuarios gratuitos ya no verán anuncios';

  @override
  String get changeLog_215_1 =>
      'Mejorada la eficiencia de los cálculos de informes, lo que resulta en una experiencia de usuario más fluida';

  @override
  String get changeLog_216_1 =>
      'Las coordenadas de los lugares de pesca ahora son editables';

  @override
  String get changeLog_216_2 =>
      'Mejorados los mensajes de error de copia de seguridad y restauración';

  @override
  String get changeLog_216_3 =>
      'Se solucionó un problema donde a veces el botón de \"Direcciones\" del lugar de pesca no funcionaba';

  @override
  String get changeLog_216_4 =>
      'Se solucionó un problema donde la galería de fotos a veces aparecía vacía';

  @override
  String get changeLog_216_5 => 'Se solucionaron varios fallos';

  @override
  String get changeLog_220_1 =>
      'Se agregó una vista de calendario de viajes y capturas a la página \"Más\"';

  @override
  String get changeLog_220_2 =>
      'Se solucionaron múltiples problemas con la visualización de cebos en la página \"Estadísticas\"';

  @override
  String get changeLog_220_3 =>
      'Se solucionó un fallo cuando los datos de la foto se volvían ilegibles';

  @override
  String get changeLog_230_1 =>
      'Agregar seguimiento GPS en vivo que se puede habilitar tocando el botón %s en el mapa';

  @override
  String get changeLog_230_2 =>
      'Los países cuya configuración regional lo permite, ahora pueden usar comas como puntos decimales';

  @override
  String get changeLog_230_3 =>
      'Se solucionó un problema donde la hora y ubicación de una foto no siempre se usaban al agregar una captura';

  @override
  String get changeLog_230_4 =>
      'Se solucionó un error donde se mostraban las capturas incorrectas en la página de estadísticas';

  @override
  String get changeLog_230_5 =>
      'Correcciones menores de errores en la interfaz de usuario';

  @override
  String get changeLog_232_1 =>
      'Se solucionó un problema donde no se podían establecer las horas de inicio y fin del viaje';

  @override
  String get changeLog_233_1 =>
      'Se solucionó un problema donde las fechas de inicio y fin del viaje no eran seleccionables desde el menú \"Gestionar Campos\"';

  @override
  String get changeLog_233_2 => 'Algunas mejoras generales de estabilidad';

  @override
  String get changeLog_234_1 =>
      'Ahora se le advertirá cuando salga de una página sin presionar primero el botón \"GUARDAR\"';

  @override
  String get changeLog_234_2 =>
      'La hora de inicio establecida manualmente de un viaje ahora se utiliza al obtener datos de atmósfera y clima';

  @override
  String get changeLog_234_3 =>
      'Se solucionó un problema donde las fotos no se mostraban en la galería al agregar una captura';

  @override
  String get changeLog_234_4 =>
      'Se solucionó un problema donde el mapa no siempre podía obtener su ubicación actual';

  @override
  String get changeLog_240_1 => 'Se agregó soporte para el modo oscuro';

  @override
  String get changeLog_240_2 =>
      'Se eliminaron los dígitos decimales en las estadísticas de longitud de un viaje';

  @override
  String get changeLog_240_3 =>
      'La selección del período de tiempo de estadísticas ahora se guarda entre lanzamientos de la aplicación';

  @override
  String get changeLog_240_4 =>
      'Se agregó \"Soleado\" como condición del cielo';

  @override
  String get changeLog_240_5 =>
      'Los campos de notas ahora pueden incluir líneas en blanco';

  @override
  String get changeLog_240_6 =>
      'Los campos de notas ya no se truncarán a 4 líneas';

  @override
  String get changeLog_241_1 =>
      'Se solucionó un bloqueo al obtener datos de atmósfera y clima';

  @override
  String get changeLog_241_2 =>
      'Se solucionó un bloqueo raro al agregar una captura';

  @override
  String get changeLog_241_3 =>
      'Se solucionó un problema donde el lugar de pesca se restablecía al agregar una captura';

  @override
  String get changeLog_241_4 =>
      'Al agregar viajes, ahora se te da la opción de establecer automáticamente los campos existentes según las capturas seleccionadas';

  @override
  String get changeLog_241_5 =>
      'Varios mejoras generales de estabilidad y correcciones de fallos';

  @override
  String get changeLog_243_1 =>
      'Se corrigieron datos de atmósfera y clima obtenidos inexactos';

  @override
  String get changeLog_250_1 =>
      'Los datos de mareas ahora se pueden obtener de WorldTides™';

  @override
  String get changeLog_250_2 => 'Se agregó la hora del día \"Tarde\"';

  @override
  String get changeLog_250_3 =>
      'Se corrigió un problema donde no se podía agregar un lugar de pesca si estaba demasiado cerca de otro lugar';

  @override
  String get changeLog_250_4 =>
      'Se corrigió un problema al ingresar valores decimales para idiomas que utilizan comas como separadores';

  @override
  String get changeLog_250_5 =>
      'Se corrigió un problema donde no se podía leer la ubicación de las fotos';

  @override
  String get changeLog_251_1 =>
      'Se corrigió un problema donde las configuraciones regionales que no son de EE. UU. no podían cambiar sus unidades de medida';

  @override
  String get changeLog_252_1 =>
      'Las copias de seguridad automáticas ahora se activan con cambios en capturas, viajes y cebos';

  @override
  String get changeLog_252_2 =>
      'Se corrigió el signo negativo duplicado en las alturas de las mareas';

  @override
  String get changeLog_252_3 =>
      'Se corrigió un problema donde los informes personalizados no eran seleccionables después de actualizar a Pro';

  @override
  String get changeLog_252_4 =>
      'Se corrigieron valores de longitud/peso de captura vacíos que aparecían en las listas de estadísticas de captura';

  @override
  String get changeLog_260_1 =>
      'Los usuarios Pro ahora pueden exportar sus datos a una hoja de cálculo a través de Más > Exportar CSV.';

  @override
  String get changeLog_260_2 =>
      'Todos los usuarios ahora pueden agregar equipo y adjuntarlo a las capturas.';

  @override
  String get changeLog_260_3 =>
      'Se solucionó un problema donde el nombre de un cebo se cortaba por el texto de variante en la lista de cebos.';

  @override
  String get changeLog_260_4 =>
      'Los datos obtenidos automáticamente ahora se actualizan cuando cambia el lugar de pesca de una captura.';

  @override
  String get changeLog_260_5 =>
      'Los datos de atmósfera y clima ahora se obtienen automáticamente para los viajes.';

  @override
  String get changeLog_270_1 =>
      'Se agregó un contador de especies capturadas en tiempo real (función Pro) a la página Más.';

  @override
  String get changeLog_270_2 =>
      'Se agregó un botón para copiar la captura (función Pro) al ver una captura.';

  @override
  String get changeLog_270_3 => 'Se agregó una foto a las variantes de cebos.';

  @override
  String get changeLog_270_4 =>
      'Se agregaron condiciones del agua a los viajes.';

  @override
  String get changeLog_270_5 =>
      'Se agregaron notificaciones de respaldo fallido.';

  @override
  String get changeLog_270_6 =>
      'Se agregaron alturas bajas y altas a las tablas de mareas.';

  @override
  String get changeLog_270_7 =>
      'Se agregó metros por segundo como una opción de unidad de velocidad del viento.';

  @override
  String get changeLog_270_8 =>
      'Se solucionó un problema donde los informes mostraban los mismos datos para diferentes períodos de tiempo.';

  @override
  String get changeLog_270_9 =>
      'Se solucionó un problema donde no se podía elegir la ubicación de guardado del CSV en algunos dispositivos.';

  @override
  String get changeLog_270_10 =>
      'Se solucionó un problema donde no se podían compartir capturas o viajes en algunos dispositivos.';

  @override
  String get changeLog_270_11 =>
      'Se solucionó un problema donde el informe de Resumen del Viaje mostraba valores incorrectos de mejor longitud y peso.';

  @override
  String get changeLog_270_12 =>
      'Se solucionó un error de red erróneo al intentar enviarnos comentarios.';

  @override
  String get changeLog_270_13 =>
      'El lugar de pesca ahora se puede omitir al agregar una captura.';

  @override
  String get changeLog_270_14 =>
      'El lugar de pesca ahora se puede eliminar de una captura.';

  @override
  String get changeLog_270_15 =>
      'Los archivos CSV exportados ahora incluyen columnas de latitud, longitud y campos personalizados.';

  @override
  String get changeLog_270_16 =>
      'El sello \"Skunked\" ahora dice \"Blanked\" para los usuarios del Reino Unido.';

  @override
  String get changeLog_271_1 =>
      'El gráfico de mareas ahora muestra las etiquetas del eje y en la unidad correcta.';

  @override
  String get changeLog_271_2 =>
      'Se solucionó el problema donde algunas fotos de captura se eliminaban después de una actualización de la aplicación.';

  @override
  String get changeLog_272_1 =>
      'Se solucionó el bloqueo al abrir enlaces externos.';

  @override
  String get changeLog_273_1 =>
      'Se agregó el número de capturas a los detalles del lugar de pesca.';

  @override
  String get changeLog_273_2 =>
      'Se agregó el valor de datum de marea a los detalles de la marea.';

  @override
  String get changeLog_273_3 =>
      'Se solucionó el zoom poco confiable en las fotos.';

  @override
  String get changeLog_273_4 =>
      'Se solucionó el error al obtener datos meteorológicos.';

  @override
  String get changeLog_273_5 =>
      'Se solucionaron los valores de altura de marea.';

  @override
  String get changeLog_273_6 => 'Se solucionó el bloqueo al iniciar rutas GPS.';

  @override
  String get changeLog_273_7 =>
      'Se solucionó el texto cortado en los gráficos de barras de estadísticas.';

  @override
  String get changeLog_274_1 =>
      'Se solucionó el problema al agregar texto a algunos campos de texto.';

  @override
  String get changeLog_275_1 =>
      'Se solucionó el problema de que se eliminara el decimal del peso de una captura.';

  @override
  String get changeLog_275_2 =>
      'Se solucionó el redondeo incorrecto de las temperaturas del agua.';

  @override
  String get changeLog_275_3 =>
      'Se agregó una advertencia de \"no importable\" a la exportación de CSV.';

  @override
  String get changeLog_276_1 =>
      'Se solucionó el formato de número en algunas regiones.';

  @override
  String get changeLog_277_1 =>
      'Se solucionó el bloqueo cuando la ubicación del dispositivo estaba desactivada.';

  @override
  String get changeLog_277_2 =>
      'Se solucionó un bloqueo raro durante la incorporación.';

  @override
  String get changeLog_277_3 =>
      'Se solucionó el formato de número para los usuarios en Noruega.';

  @override
  String get changeLog_278_1 =>
      'Se solucionó un fallo al solicitar permiso de ubicación.';

  @override
  String get changeLog_278_2 =>
      'Se solucionó el problema de congelamiento de la aplicación al iniciar para usuarios en ciertas regiones.';

  @override
  String get translationWarningPageTitle => 'Traducciones';

  @override
  String get translationWarningPageDescription =>
      'El texto en Anglers\' Log ha sido traducido usando IA. Si notas un error o algo no tiene sentido, por favor toca Más y luego Enviar comentarios. ¡Tu ayuda siempre es apreciada, gracias!';

  @override
  String get backupRestorePageOpenDoc => 'Abrir documentación';

  @override
  String get backupRestorePageWarningApple =>
      'La función de copia de seguridad y restauración ha demostrado ser poco confiable, y estamos considerando otras opciones. Mientras tanto, se recomienda encarecidamente que configures copias de seguridad automáticas para todo tu dispositivo a fin de garantizar que no se pierdan datos. Para obtener más información, visita la documentación de Apple.';

  @override
  String get backupRestorePageWarningGoogle =>
      'La función de copia de seguridad y restauración ha demostrado ser poco confiable, y estamos considerando otras opciones. Mientras tanto, se recomienda encarecidamente que configures copias de seguridad automáticas para todo tu dispositivo a fin de garantizar que no se pierdan datos. Para obtener más información, visita la documentación de Google.';

  @override
  String get backupRestorePageWarningOwnRisk =>
      'Utiliza esta función bajo tu propio riesgo.';

  @override
  String get proPageBackupWarning =>
      'La copia de seguridad automática ha demostrado ser poco confiable. Usa esta función bajo tu propio riesgo mientras investigamos. Para más detalles, visita las páginas de Copia de seguridad y Restauración en el menú Más.';

  @override
  String get changeLog_279_1 => 'Se corrigieron algunos errores de interfaz.';

  @override
  String get changeLog_279_2 =>
      'Se añadió una advertencia para reflejar la falta de confiabilidad de la copia de seguridad en la nube.';

  @override
  String get changeLog_279_3 => 'Agregar traducciones al español.';
}
