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

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT SST_ID, SST_NAME, SST_CAPTION, SST_REPORT, SST_LST,
		(
			SELECT SST_CAPTION
			FROM dbo.SystemTypeTable b
			WHERE b.SST_ID = a.SST_ID_SUB
		) AS SST_SUB,
		(
			SELECT SST_CAPTION
			FROM dbo.SystemTypeTable c
			WHERE c.SST_ID = a.SST_ID_MOS
		) AS SST_MOS
	FROM dbo.SystemTypeTable a
	WHERE SST_ACTIVE = ISNULL(@active, SST_ACTIVE)
	ORDER BY SST_NAME

	SET NOCOUNT OFF
END








