CREATE OR REPLACE PROCEDURE GENERATE_ID_NUMBER(NUM_OF_IDS IN NUMBER)
/*******************************************************************
  @AUTHOR��YANYUN
  @CREATE_DATE:2023-03-25
  @DESCRIPTION:�Ĵ洢����������������й���½�������֤���룬��������
  ������NUM_OF_IDS�������������֤������ʱ��ID_NUMBER_TEMP_TABLE����
  @MODIFICATION_HISTORY��
         M0.AUTHOR_CREATE-DATE_DESCRIPTION 20230325
  ********************************************************************/
 AS
  ID_NUMBER       VARCHAR2(20);
  REGION_CODE     VARCHAR2(20);
  BIRTHDAY        VARCHAR2(20);
  CHECK_CODE      VARCHAR2(20);
  SEQUENCE_NUMBER VARCHAR2(20);
  LOG_STEP        INTEGER;
  PROCNAME        VARCHAR2(80);
  LOG_MESSAGE     VARCHAR2(1000);
BEGIN
  LOG_STEP    := 0;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '������ʼ������';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  -- ������֤������ʱ��
  DELETE FROM ID_NUMBER_TEMP_TABLE;

  LOG_STEP    := 1;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '������֤������ʱ�����';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  FOR I IN 1 .. NUM_OF_IDS LOOP
    -- ���ȡ���й�ʡ�����ش����
    SELECT TO_CHAR(REGION_CODE)
      INTO REGION_CODE
      FROM (SELECT REGION_CODE
              FROM CHINA_REGION_CODE
             ORDER BY DBMS_RANDOM.VALUE())
     WHERE ROWNUM = 1;
  
    -- ���������������
    BIRTHDAY := TO_CHAR(TO_DATE('1937-01-01', 'YYYY-MM-DD') +
                        DBMS_RANDOM.VALUE(1, 31031),
                        'YYYYMMDD');
  
    -- ����˳����
    SEQUENCE_NUMBER := TO_CHAR(MOD(DBMS_RANDOM.VALUE(1, 999), 1000),
                               'FM000');
  
    -- ����У����
    CHECK_CODE := TO_CHAR(DBMS_RANDOM.VALUE(1, 10), 'FM00');
    CASE CHECK_CODE
      WHEN '01' THEN
        CHECK_CODE := '1';
      WHEN '02' THEN
        CHECK_CODE := '2';
      WHEN '03' THEN
        CHECK_CODE := '3';
      WHEN '04' THEN
        CHECK_CODE := '4';
      WHEN '05' THEN
        CHECK_CODE := '5';
      WHEN '06' THEN
        CHECK_CODE := '6';
      WHEN '07' THEN
        CHECK_CODE := '7';
      WHEN '08' THEN
        CHECK_CODE := '8';
      WHEN '09' THEN
        CHECK_CODE := '9';
      ELSE
        CHECK_CODE := 'X';
    END CASE;
  
    -- ƴ�Ӻ���
    ID_NUMBER := TO_CHAR(REGION_CODE || BIRTHDAY || SEQUENCE_NUMBER ||
                         CHECK_CODE);
  
    -- �����ɵ����֤������뵽��ʱ����
    INSERT INTO ID_NUMBER_TEMP_TABLE (ID_NUMBER) VALUES (ID_NUMBER);
    COMMIT;
  END LOOP;

  LOG_STEP    := 2;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '���֤�����Ѳ��뵽��ʱ���У����������' || NUM_OF_IDS || '������';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

EXCEPTION
  WHEN OTHERS THEN
    -- ��¼�쳣��Ϣ
    LOG_STEP    := 2;
    PROCNAME    := UPPER('generate_id_number');
    LOG_MESSAGE := '�����쳣���쳣��ϢΪ��' || TO_CHAR(SQLCODE) || TO_CHAR(SQLERRM);
    SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);
    RAISE;
  
END;
/
