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

CREATE PROCEDURE [dbo].[CLIENT_TYPE_CHECK_NAME] 
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT CLT_ID
	FROM dbo.ClientTypeTable
	WHERE CLT_NAME = @name

	SET NOCOUNT OFF
END
