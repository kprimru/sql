USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 28.10.2008
��������:	  �������� ���������� � ���������
               ���������� � ��������� �������
*/

ALTER PROCEDURE [dbo].[LOCK_DELETE]
	@docid INT,
	@tablename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.LockTable
	WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[LOCK_DELETE] TO rl_admin_lock_w;
GO