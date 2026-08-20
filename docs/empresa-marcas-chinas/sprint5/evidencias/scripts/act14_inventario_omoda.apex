try {
    Map<String,Object> result = RM_VN_Inventario_Ctrl.getRecords('OMODA','2026','QA OMODA', null, null, null, null, null, null, null, 'No', null, 'No', 1, false);
    System.debug('SPRINT5_ACT14_OMODA_RESULT=' + JSON.serialize(result));
} catch (Exception e) {
    System.debug('SPRINT5_ACT14_OMODA_ERROR_TYPE=' + e.getTypeName());
    System.debug('SPRINT5_ACT14_OMODA_ERROR_MSG=' + e.getMessage());
}
