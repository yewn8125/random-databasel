CREATE OR REPLACE PROCEDURE SP_RANDOM_LOG(LOG_STEP    IN NUMBER, --任务号
                                          PROCNAME    IN VARCHAR2, --存储过程名称
                                          LOG_TIME    IN TIMESTAMP DEFAULT SYSTIMESTAMP, --起始时间
                                          LOG_MESSAGE IN VARCHAR2 --任务描述
                                          )
/*******************************************************************
  @AUTHOR：YANYUN
  @CREATE_DATE:2023-03-25
  @DESCRIPTION:处理执行信息插入日志表
  @MODIFICATION_HISTORY：
         M0.AUTHOR_CREATE-DATE_DESCRIPTION 20230325
  ********************************************************************/
 AS
BEGIN
  INSERT INTO RANDOM_LOG
    (LOG_STEP, --任务号
     PROCNAME, --存储过程名称
     LOG_TIME, --起始时间
     LOG_MESSAGE --任务描述
     )
  VALUES
    (LOG_STEP, --任务号
     PROCNAME, --存储过程名称
     TO_CHAR(LOG_TIME, 'YYYY-MM-DD HH24:MI:SS:FF'), --起始时间
     LOG_MESSAGE --任务描述
     );
  COMMIT;
END;
/
