class InfluenceFactors {
  static double getDemandFactor(DateTime date) {
    switch (date.month) {
      case 1: // Janvier
      case 2: // Février
      case 11: // Novembre
      case 12: // Décembre
        return 0.9;
      case 3: // Mars
      case 10: // Octobre
        return 1.0;
      case 4: // Avril
      case 9: // Septembre
        return 1.1;
      case 5: // Mai
        return 1.2;
      case 6: // Juin
        return 1.3;
      case 7: // Juillet
        return 1.4;
      case 8: // Août
        return 1.3;
      default:
        return 1.0;
    }
  }

  static double getSupplyFactor(DateTime date) {
    switch (date.month) {
      case 1: // Janvier
      case 2: // Février
      case 12: // Décembre
        return 0.8;
      case 3: // Mars
        return 0.9;
      case 4: // Avril
      case 5: // Mai
        return 1.0;
      case 6: // Juin
        return 1.2;
      case 7: // Juillet
        return 1.3;
      case 8: // Août
        return 1.2;
      case 9: // Septembre
        return 1.4;
      case 10: // Octobre
        return 1.3;
      case 11: // Novembre
        return 1.1;
      default:
        return 1.0;
    }
  }

  static double getProductionCostFactor(DateTime date) {
    switch (date.month) {
      case 1: // Janvier
      case 2: // Février
      case 12: // Décembre
        return 1.1;
      case 6: // Juin
      case 7: // Juillet
      case 8: // Août
        return 1.2;
      default:
        return 1.0;
    }
  }

  static double getWeatherFactor(DateTime date) {
    switch (date.month) {
      case 3: // Mars
      case 4: // Avril
        return 0.9;
      case 6: // Juin
      case 7: // Juillet
        return 0.8;
      default:
        return 1.0;
    }
  }
}