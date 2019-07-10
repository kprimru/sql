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

CREATE PROCEDURE [dbo].[COUNTRY_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT CNT_NAME, CNT_ID 
	FROM dbo.CountryTable 
	WHERE CNT_ACTIVE = ISNULL(@active, CNT_ACTIVE)
	ORDER BY CNT_NAME

	SET NOCOUNT OFF
END



