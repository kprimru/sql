USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_FACT_ALL_GET]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CFM_FACT_DATE, COUNT(*) AS CFM_COUNT
	FROM dbo.ConsignmentFactMasterTable
	GROUP BY CFM_FACT_DATE
	ORDER BY CFM_FACT_DATE DESC
END



GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_FACT_ALL_GET] TO rl_consignment_p;
GO