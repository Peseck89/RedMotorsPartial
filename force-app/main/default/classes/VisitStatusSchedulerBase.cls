public without sharing class VisitStatusSchedulerBase {
    public static final String ST_NUEVO          = 'Nuevo';
    public static final String ST_PRIMERA_VISITA = 'Primera visita';
    public static final String ST_SIN_VISITA     = 'Sin visita';
    public static final String ST_RECURRENTE     = 'Visita recurrente';
    public static final String ST_PREFUGA        = 'Prefuga';
    public static final String ST_FUGA           = 'Fuga';

    public static Integer normalizeScopeSize(Integer scopeSize, Integer defaultScopeSize) {
        return (scopeSize == null || scopeSize <= 0) ? defaultScopeSize : scopeSize;
    }

    public static Date resolveToday(Date todayOverride) {
        return (todayOverride == null) ? Date.today() : todayOverride;
    }

    public static Integer fullMonthsBetween(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) return 0;
        if (endDate < startDate) return 0;

        Integer months = (endDate.year() - startDate.year()) * 12 + (endDate.month() - startDate.month());
        if (endDate.day() < startDate.day()) months--;
        return (months < 0) ? 0 : months;
    }

    public static String statusFromWorkshopVisitMonths(Integer months) {
        if (months == null) return null;
        if (months < 18) return ST_RECURRENTE;
        if (months <= 24) return ST_PREFUGA;
        return ST_FUGA;
    }

    public static String statusFromVehicleAgeMonths(Integer months) {
        if (months == null) return null;
        if (months <= 17) return ST_NUEVO;
        if (months == 18) return ST_PRIMERA_VISITA;
        return ST_SIN_VISITA;
    }
}
