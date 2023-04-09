CREATE OR REPLACE PROCEDURE GENERATE_CHINESE_NAME(NUM_OF_NAMES IN NUMBER)
/*******************************************************************
  @AUTHOR：YANYUN
  @CREATE_DATE:2023-03-26
  @DESCRIPTION:改存储过程用于随机生成中国大陆居民姓名，输入生成
  条数（NUM_OF_NAMES）插入至姓名临时表（CHINESE_NAME_TEMP_TABLE）中
  @MODIFICATION_HISTORY：
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
  LOG_MESSAGE := '参数初始化处理';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  -- 判断姓名临时表是否存在，存在则清空，不存在则创建
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
  LOG_MESSAGE := '清空姓名临时表完成';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  FOR I IN 1 .. NUM_OF_NAMES LOOP
    -- 随机生成中文姓氏
    SELECT FIRST_NAME
      INTO V_FIRST_NAME
      FROM CHINA_FIRST_NAME
     WHERE ROWNUM = 1;
  
    -- 随机生成名字字数
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
  
    -- 随机生成中文名字
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
  
    -- 判断名字的性别      
    SELECT SEX
      INTO V_SEX
      FROM (SELECT NAME_KEY_WORD, SEX
              FROM CHINA_MEN_NAME
            UNION ALL
            SELECT NAME_KEY_WORD, SEX
              FROM CHINA_WOMEN_NAME)
     WHERE NAME_KEY_WORD = SUBSTR(V_CHINESE_NAME, -1, 1);
  
    IF V_SEX = '男' THEN
      V_GENDER := 'MALE';
    ELSE
      V_GENDER := 'FEMALE';
    END IF;
  
    -- 将生成的姓名插入到临时表中 
    INSERT INTO CHINESE_NAME_TEMP_TABLE
      (CHINESE_NAME, GENDER)
    VALUES
      (V_CHINESE_NAME, V_GENDER);
    COMMIT;
  END LOOP;

  LOG_STEP    := 2;
  PROCNAME    := UPPER('generate_chinese_name');
  LOG_MESSAGE := '姓名已插入到临时表中，随机生成了' || NUM_OF_NAMES || '条数据';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

EXCEPTION
  WHEN OTHERS THEN
    -- 记录异常信息
    LOG_STEP    := 2;
    PROCNAME    := UPPER('generate_chinese_name');
    LOG_MESSAGE := '发生异常，异常信息为：' || TO_CHAR(SQLCODE) || TO_CHAR(SQLERRM);
    SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);
    RAISE;
END;
/
