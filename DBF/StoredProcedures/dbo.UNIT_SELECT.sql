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

CREATE PROCEDURE [dbo].[UNIT_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT UN_ID, UN_NAME, UN_OKEI
	FROM dbo.UnitTable 
	WHERE UN_ACTIVE = ISNULL(@active, UN_ACTIVE)
	ORDER BY UN_NAME

	SET NOCOUNT OFF
END









