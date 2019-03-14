USE [BuhDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE dbo.OPEN_DOC_STATUS_SP
	@docid nvarchar(128), 
	@action tinyint,
	@hostname varchar(128) out,
             @loginame varchar(128) out,
             @tablename varchar(128)

--��������� ������������ ����������, �������� � ������ ��������������
-- ������� ���������:
--  @docid - ������������� ���������
--  @action - 1-�������� �����������; 2- �������� �����������, 3 - �������� ���������
-- �������� ���������:
--   RETURN -1 ��� ������, 0 ��� �� ������
--  @hostname - ������� �������
--  @loginame - ��� ������������
--  @tablename - �������� �������

AS
  SET NOCOUNT ON
 -- ������� �������� ������. ���� ��� �������, �� ���������� -1 � ������� � �������������
  IF @action = 1 BEGIN
    IF EXISTS(SELECT DOC_EDITING_STATUS.*
              FROM DOC_EDITING_STATUS
                   INNER JOIN master..sysprocesses sysproc ON
                   DOC_EDITING_STATUS.spid = sysproc.spid AND
                   DOC_EDITING_STATUS.hostname = sysproc.hostname AND
                   DOC_EDITING_STATUS.hostprocess = sysproc.hostprocess AND
                   DOC_EDITING_STATUS.loginame = sysproc.loginame AND
                   DOC_EDITING_STATUS.login_time = sysproc.login_time                   
              WHERE DOC_EDITING_STATUS.docid = @docid AND DOC_EDITING_STATUS.tablename = @tablename) BEGIN
	      SELECT 
		@hostname = DOC_EDITING_STATUS.hostname, 
		@loginame = DOC_EDITING_STATUS.loginame
	      FROM DOC_EDITING_STATUS
	      WHERE docid = @docid AND tablename = @tablename
	      RETURN(-1)  -- ������ ������
	END
    ELSE BEGIN -- ��������� ������ � ������ ������ � �� �������� � ����. DOC_EDITING_STATUS
      DELETE DOC_EDITING_STATUS
      WHERE docid = @docid AND tablename=@tablename
      INSERT INTO DOC_EDITING_STATUS(docid, spid, hostname, hostprocess, loginame, login_time, tablename)
      SELECT @docid,
             sysproc.spid,
             sysproc.hostname,
             sysproc.hostprocess,
             sysproc.loginame,
             sysproc.login_time,
             @tablename
      FROM master..sysprocesses sysproc
      WHERE sysproc.spid = @@spid
      RETURN(0)  -- ������ �������� ��� �������� � �����������. ������ ����������� � ���� DOC_EDITING_STATUS
    END
  END

-- ������ ��������� ������ ��� ��������� ������� �� ������
  IF @action = 2 BEGIN -- �������� ������ � �������� ���������� � ���
    DELETE DOC_EDITING_STATUS
    WHERE docid = @docid AND
          spid = @@spid AND
         tablename = @tablename
    RETURN(0)
  END

--  -- ������� �������� ������. ���� ��� �������, �� ���������� -1 � ������� � �������������
  IF @action = 3 BEGIN
    IF EXISTS(SELECT DOC_EDITING_STATUS.*
              FROM DOC_EDITING_STATUS
                   INNER JOIN master..sysprocesses sysproc ON
                   DOC_EDITING_STATUS.spid = sysproc.spid AND
                   DOC_EDITING_STATUS.hostname = sysproc.hostname AND
                   DOC_EDITING_STATUS.hostprocess = sysproc.hostprocess AND
                   DOC_EDITING_STATUS.loginame = sysproc.loginame AND
                   DOC_EDITING_STATUS.login_time = sysproc.login_time
              WHERE DOC_EDITING_STATUS.docid = @docid AND DOC_EDITING_STATUS.tablename = @tablename) BEGIN
	      SELECT 
		@hostname = DOC_EDITING_STATUS.hostname,
             		@loginame = DOC_EDITING_STATUS.loginame
       	     FROM DOC_EDITING_STATUS
      	     WHERE docid = @docid AND tablename=@tablename
      	     RETURN(-1) -- ������ ������
    	END
    ELSE BEGIN
      DELETE DOC_EDITING_STATUS
      WHERE docid = @docid AND
          spid = @@spid AND
          tablename=@tablename
      RETURN(0)
    END
  END
  
  SET NOCOUNT OFF
RETURN(0)