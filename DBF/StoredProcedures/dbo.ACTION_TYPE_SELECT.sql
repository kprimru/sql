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

CREATE PROCEDURE [dbo].[ACTION_TYPE_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT ACTT_ID, ACTT_NAME 
	FROM dbo.ActionType
	WHERE ACTT_ACTIVE = ISNULL(@active, ACTT_ACTIVE)
	ORDER BY ACTT_NAME

	SET NOCOUNT OFF
END
