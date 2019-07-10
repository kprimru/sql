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

CREATE PROCEDURE [dbo].[POSITION_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT POS_ID, POS_NAME, (SELECT COUNT(*) FROM dbo.TOPersonalTable WHERE TP_ID_POS = POS_ID) AS CNT
	FROM dbo.PositionTable  
	WHERE POS_ACTIVE = ISNULL(@active, POS_ACTIVE)
	ORDER BY POS_NAME

	SET NOCOUNT OFF
END




