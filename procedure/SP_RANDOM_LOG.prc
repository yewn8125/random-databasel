CREATE OR REPLACE PROCEDURE SP_RANDOM_LOG(LOG_STEP    IN NUMBER, --�����
                                          PROCNAME    IN VARCHAR2, --�洢��������
                                          LOG_TIME    IN TIMESTAMP DEFAULT SYSTIMESTAMP, --��ʼʱ��
                                          LOG_MESSAGE IN VARCHAR2 --��������
                                          )
/*******************************************************************
  @AUTHOR��YANYUN
  @CREATE_DATE:2023-03-25
  @DESCRIPTION:����ִ����Ϣ������־��
  @MODIFICATION_HISTORY��
         M0.AUTHOR_CREATE-DATE_DESCRIPTION 20230325
  ********************************************************************/
 AS
BEGIN
  INSERT INTO RANDOM_LOG
    (LOG_STEP, --�����
     PROCNAME, --�洢��������
     LOG_TIME, --��ʼʱ��
     LOG_MESSAGE --��������
     )
  VALUES
    (LOG_STEP, --�����
     PROCNAME, --�洢��������
     TO_CHAR(LOG_TIME, 'YYYY-MM-DD HH24:MI:SS:FF'), --��ʼʱ��
     LOG_MESSAGE --��������
     );
  COMMIT;
END;
/
