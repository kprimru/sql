USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[VRHView]
AS
SELECT
		PR_NAME, PR_ID,
		VRH_RIC_NUM, VRH_TO_NUM, VRH_TO_NAME,
		VRH_INN, VRH_REGION, VRH_CITY, VRH_ADDR,
		VRH_FIO_1, VRH_JOB_1, VRH_TELS_1,
		VRH_FIO_2, VRH_JOB_2, VRH_TELS_2,
		VRH_FIO_3, VRH_JOB_3, VRH_TELS_3,
		VRH_FIO_4, VRH_JOB_4, VRH_TELS_4,
		VRH_FIO_5, VRH_JOB_5, VRH_TELS_5,
		VRH_SERV, VRH_DISTR, VRH_COMMENT

FROM	dbo.VMIReportHistoryTable	A	INNER JOIN
		dbo.PeriodTable				B	ON	A.VRH_ID_PERIOD=B.PR_ID
GO