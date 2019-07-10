USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ����� ������ � ������������� 
               ������� �� ����� �������
*/

CREATE PROCEDURE [dbo].[LOCK_GET] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT LC_TABLE, LC_DOC_ID, LC_LOGIN_NAME, LC_NT_USER, LC_HOST_NAME, 
		   CONVERT(VARCHAR, LC_LOGIN_TIME, 113) AS LC_LOGIN_TIME, LC_SP_ID, 
		   CONVERT(VARCHAR, LC_LOCK_TIME, 113) AS LC_LOCK_TIME 
	FROM dbo.LockTable 
	ORDER BY LC_TABLE, LC_DOC_ID

	SET NOCOUNT OFF
END