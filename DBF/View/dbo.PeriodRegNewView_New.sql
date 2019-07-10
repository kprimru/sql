USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PeriodRegNewView_New]
AS
SELECT	
		RNN_ID = A.REG_ID,
		B.PR_NAME,	B.PR_DATE,	RNN_ID_PERIOD = A.REG_ID_PERIOD,
		C.SYS_SHORT_NAME,	RNN_ID_SYSTEM = A.REG_ID_SYSTEM,
		RNN_DISTR_NUM = A.REG_DISTR_NUM,
		RNN_COMP_NUM = A.REG_COMP_NUM,
		D.SH_SHORT_NAME,	RNN_ID_HOST = A.REG_ID_HOST,
		E.SST_NAME,		RNN_ID_TYPE = A.REG_ID_TYPE,
		RNN_DATE = A.REG_DATE,
		RNN_DATE_ON = A.REG_DATE,
		RNN_COMMENT = A.REG_COMMENT,
		RNN_NUM_CLIENT = A.REG_NUM_CLIENT,
		RNN_PSEDO_CLIENT = A.REG_PSEDO_CLIENT,
--		COUR_NAME,		RNN_ID_COUR,
		F.SNC_NET_COUNT,	RNN_ID_NET = A.REG_ID_NET

FROM	dbo.PeriodRegNewDistrView			N
		INNER JOIN dbo.PeriodRegTable		A ON	N.REG_DISTR_NUM = A.REG_DISTR_NUM
												AND N.REG_COMP_NUM = a.REG_COMP_NUM
												AND N.REG_ID_PERIOD = A.REG_ID_PERIOD
		INNER JOIN dbo.PeriodTable			B ON A.REG_ID_PERIOD = B.PR_ID
		INNER JOIN dbo.SystemTable			C ON	A.REG_ID_SYSTEM = C.SYS_ID	
												AND N.SYS_ID_HOST = N.SYS_ID_HOST
		INNER JOIN dbo.SubHostTable			D ON A.REG_ID_HOST = D.SH_ID
		INNER JOIN dbo.SystemTypeTable		E ON A.REG_ID_TYPE = E.SST_ID
		INNER JOIN dbo.SystemNetCountTable	F ON A.REG_ID_NET = F.SNC_ID		
WHERE NOT EXISTS
	(
		SELECT *
		FROM dbo.DistrExchange z
		WHERE z.NEW_HOST = c.SYS_ID_HOST
			AND z.NEW_NUM = a.REG_DISTR_NUM
			AND z.NEW_COMP = a.REG_COMP_NUM
	)
--		dbo.CourierTable		G	ON A.RNN_ID_COUR= G.COUR_ID
