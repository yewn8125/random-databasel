CREATE OR REPLACE PROCEDURE GENERATE_CHINESE_NAME(NUM_OF_NAMES IN NUMBER)
/*******************************************************************
  @AUTHOR��YANYUN
  @CREATE_DATE:2023-03-26
  @DESCRIPTION:�Ĵ洢����������������й���½������������������
  ������NUM_OF_NAMES��������������ʱ��CHINESE_NAME_TEMP_TABLE����
  @MODIFICATION_HISTORY��
         M0.AUTHOR_CREATE-DATE_DESCRIPTION 20230325
  ********************************************************************/
 AS
  V_CHINESE_NAME  VARCHAR2(20);
  V_FIRST_NAME    VARCHAR2(20);
  V_NAME_KEY_WORD VARCHAR2(20);
  V_SEX         VARCHAR2(20);
  V_GENDER        VARCHAR2(20);
  V_WORD_NUM      NUMBER;
  LOG_STEP      INTEGER;
  PROCNAME      VARCHAR2(80);
  LOG_MESSAGE   VARCHAR2(1000);
BEGIN
  LOG_STEP    := 0;
  PROCNAME    := UPPER('generate_chinese_name');
  LOG_MESSAGE := '������ʼ������';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  -- �ж�������ʱ���Ƿ���ڣ���������գ��������򴴽�
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE CHINESE_NAME_TEMP_TABLE';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -942 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE CHINESE_NAME_TEMP_TABLE (CHINESE_NAME VARCHAR2(20), GENDER VARCHAR2(10))';
      ELSE
        RAISE;
      END IF;
  END;

  LOG_STEP    := 1;
  PROCNAME    := UPPER('generate_chinese_name');
  LOG_MESSAGE := '���������ʱ�����';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  FOR I IN 1 .. NUM_OF_NAMES LOOP
    -- ���������������
    SELECT FIRST_NAME
      INTO V_FIRST_NAME
      FROM CHINA_FIRST_NAME
     WHERE ROWNUM = 1;
  
    -- ���������������
    SELECT CASE
             WHEN ROUND(DBMS_RANDOM.VALUE, 3) BETWEEN 0 AND 0.932 THEN
              '2'
             WHEN ROUND(DBMS_RANDOM.VALUE, 3) BETWEEN 0.932 AND 0.977 THEN
              '1'
             WHEN ROUND(DBMS_RANDOM.VALUE, 3) BETWEEN 0.977 AND 0.994 THEN
              '3'
             WHEN ROUND(DBMS_RANDOM.VALUE, 3) BETWEEN 0.994 AND 1.000 THEN
              '5'
             ELSE
              '4'
           END AS WORD_NUM
      INTO V_WORD_NUM
      FROM DUAL;
  
    -- ���������������
    V_CHINESE_NAME := V_FIRST_NAME;
    FOR J IN 1 .. V_WORD_NUM LOOP
      SELECT NAME_KEY_WORD
        INTO V_NAME_KEY_WORD
        FROM (SELECT NAME_KEY_WORD
                FROM (SELECT NAME_KEY_WORD
                        FROM CHINA_MEN_NAME
                      UNION ALL
                      SELECT NAME_KEY_WORD
                        FROM CHINA_WOMEN_NAME)
               ORDER BY DBMS_RANDOM.VALUE)
       WHERE ROWNUM = 1;
      V_CHINESE_NAME := V_CHINESE_NAME || V_NAME_KEY_WORD;
    END LOOP;
  
    -- �ж����ֵ��Ա�      
    SELECT SEX
      INTO V_SEX
      FROM (SELECT NAME_KEY_WORD, SEX
              FROM CHINA_MEN_NAME
            UNION ALL
            SELECT NAME_KEY_WORD, SEX
              FROM CHINA_WOMEN_NAME)
     WHERE NAME_KEY_WORD = SUBSTR(V_CHINESE_NAME, -1, 1);
  
    IF V_SEX = '��' THEN
      V_GENDER := 'MALE';
    ELSE
      V_GENDER := 'FEMALE';
    END IF;
  
    -- �����ɵ��������뵽��ʱ���� 
    INSERT INTO CHINESE_NAME_TEMP_TABLE
      (CHINESE_NAME, GENDER)
    VALUES
      (V_CHINESE_NAME, V_GENDER);
    COMMIT;
  END LOOP;

  LOG_STEP    := 2;
  PROCNAME    := UPPER('generate_chinese_name');
  LOG_MESSAGE := '�����Ѳ��뵽��ʱ���У����������' || NUM_OF_NAMES || '������';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

EXCEPTION
  WHEN OTHERS THEN
    -- ��¼�쳣��Ϣ
    LOG_STEP    := 2;
    PROCNAME    := UPPER('generate_chinese_name');
    LOG_MESSAGE := '�����쳣���쳣��ϢΪ��' || TO_CHAR(SQLCODE) || TO_CHAR(SQLERRM);
    SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);
    RAISE;
END;
/
