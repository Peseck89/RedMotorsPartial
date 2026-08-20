try {
    Map<String,Object> result = RM_VN_Inventario_Ctrl.getRecords('JAECOO','2026','QA JAECOO', null, null, null, null, null, null, null, 'No', null, 'No', 1, false);
    System.debug('SPRINT5_ACT14_JAECOO_RESULT=' + JSON.serialize(result));
} catch (Exception e) {
    System.debug('SPRINT5_ACT14_JAECOO_ERROR_TYPE=' + e.getTypeName());
    System.debug('SPRINT5_ACT14_JAECOO_ERROR_MSG=' + e.getMessage());
}
