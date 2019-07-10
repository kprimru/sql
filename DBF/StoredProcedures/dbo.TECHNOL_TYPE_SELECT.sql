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

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT TT_ID, TT_NAME, TT_REG, TT_COEF
	FROM dbo.TechnolTypeTable 
	WHERE TT_ACTIVE = ISNULL(@active, TT_ACTIVE)
	ORDER BY TT_NAME

	SET NOCOUNT OFF
END







