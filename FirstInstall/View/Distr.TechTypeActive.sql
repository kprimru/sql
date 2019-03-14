USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Distr].[TechTypeActive] 
--WITH SCHEMABINDING
AS
	SELECT 
		TT_ID_MASTER, TT_ID, TT_NAME, TT_SHORT, 
		TT_REG, TT_COEF, TT_DATE, TT_END
	FROM 
		Distr.TechTypeAll
	WHERE TT_REF = 1