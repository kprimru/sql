USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[DOCUMENT_TRY_DELETE]
	@docid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''	

	SELECT @res AS RES, @txt AS TXT
END
