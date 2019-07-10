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

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_GET] 
	@systemnetcountid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT SN_NAME, SN_ID, SNC_NET_COUNT, SNC_TECH, SNC_ACTIVE, SNC_ODON, SNC_ODOFF, SNC_SHORT
	FROM 
		dbo.SystemNetCountTable a INNER JOIN
		dbo.SystemNetTable b ON a.SNC_ID_SN = b.SN_ID
	WHERE SNC_ID = @systemnetcountid 

	SET NOCOUNT OFF
END






