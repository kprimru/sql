USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[OPEN_DOC_STATUS_SP]
	@docid VARCHAR(20),
	@action TINYINT,
	@hostname VARCHAR(128),
    @loginame VARCHAR(256),
    @tablename VARCHAR(128),
    @ntname VARCHAR(128),
    @locktime VARCHAR(128)
WITH EXECUTE AS OWNER

--��������� ������������ ����������, �������� � ������ ��������������
-- ������� ���������:
--  @docid - ������������� ���������
--  @action - 1-�������� �����������; 2- �������� �����������, 3 - �������� ���������
-- �������� ���������:
--   RETURN -1 ��� ������, 0 ��� �� ������
--  @hostname - ������� �������
--  @ntname - ����� ������������
--  @loginame - ��� ������������
--  @tablename - �������� �������
--  @locktime - ����� ����������

AS
BEGIN
	SET NOCOUNT ON
	--������� �������� ������. ���� ��� �������, �� ���������� -1 � ������� � �������������
	IF @action = 1 
	BEGIN
		IF EXISTS(
               SELECT a.*
               FROM dbo.LockTable a INNER JOIN 
                    master..sysprocesses b ON a.LC_SP_ID = b.spid AND
                                              a.LC_HOST_NAME = b.hostname AND
                                              a.LC_HOST_PROCESS = b.hostprocess AND
                                              a.LC_LOGIN_NAME = b.loginame AND
                                              a.LC_LOGIN_TIME = b.login_time                   
               WHERE a.LC_DOC_ID = @docid AND 
                     a.LC_TABLE = @tablename
             ) 
		BEGIN
			SELECT -1 AS LC_RESULT, LC_HOST_NAME, LC_LOGIN_NAME, LC_NT_USER, 
				   CONVERT(varchar, LC_LOCK_TIME, 113) AS LC_LOCK_TIME
			FROM dbo.LockTable a
			WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename
		END
		ELSE 
		BEGIN -- ��������� ������ � ������ ������ � �� �������� � ����. DOC_EDITING_STATUS
			DELETE 
			FROM dbo.LockTable
			WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename

			INSERT INTO dbo.LockTable(LC_DOC_ID, LC_SP_ID, LC_HOST_NAME, LC_HOST_PROCESS, 
                              LC_LOGIN_NAME, LC_LOGIN_TIME, LC_LOCK_TIME, LC_TABLE, LC_NT_USER)
		        SELECT 
					@docid, a.spid, RTRIM(a.hostname), RTRIM(a.hostprocess), RTRIM(ORIGINAL_LOGIN()), 
					a.login_time, GETDATE(), @tablename, @ntname
				FROM master..sysprocesses a
				WHERE a.spid = @@spid
				SELECT 0 AS LC_RESULT  
			-- ������ �������� ��� �������� � �����������. ������ ����������� � ���� DOC_EDITING_STATUS
		END
	END

-- ������ ��������� ������ ��� ��������� ������� �� ������
	IF @action = 2 
    BEGIN -- �������� ������ � �������� ���������� � ���
		DELETE 
		FROM dbo.LockTable
		WHERE 
			LC_DOC_ID = @docid AND
			LC_SP_ID = @@spid AND
            LC_TABLE = @tablename
		SELECT 0 AS LC_RESULT
	END
  
	SET NOCOUNT OFF
END





