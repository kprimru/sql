USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Kladr].[KLADR_RELOAD]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		/*
		TRUNCATE TABLE Kladr.Altnames

		INSERT INTO Kladr.Altnames (KA_OLDCODE, KA_NEWCODE, KA_LEVEL)
		SELECT OLDCODE, NEWCODE, LEVEL
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select OLDCODE, NEWCODE, LEVEL from ALTNAMES')

		TRUNCATE TABLE Kladr.Doma

		INSERT INTO Kladr.Doma (KD_NAME, KD_KORP, KD_SOCR, KD_CODE, KD_INDEX, KD_GNINMB, KD_UNO, KD_OCATD)
		SELECT NAME, KORP, SOCR, CODE, [INDEX], GNINMB, UNO, OCATD
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select NAME, KORP, SOCR, CODE, INDEX, GNINMB, UNO, OCATD  from DOMA')

		TRUNCATE TABLE Kladr.Flat

		INSERT INTO Kladr.Flat (KF_NAME, KF_CODE, KF_INDEX, KF_GNINMB, KF_UNO, KF_NP)
		SELECT NAME, CODE, [INDEX], GNINMB, UNO, NP
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select NAME, CODE, INDEX, GNINMB, UNO, NP from FLAT')

		TRUNCATE TABLE Kladr.Kladr

		INSERT INTO Kladr.Kladr (KL_NAME, KL_SOCR, KL_CODE, KL_INDEX, KL_GNINMB, KL_UNO, KL_OCATD, KL_STATUS)
		SELECT NAME, SOCR, CODE, [INDEX], GNINMB, UNO, OCATD, STATUS
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select NAME, SOCR, CODE, INDEX, GNINMB, UNO, OCATD, STATUS from KLADR')

		TRUNCATE TABLE Kladr.Socrbase

		INSERT INTO Kladr.Socrbase (KSB_LEVEL, KSB_SCNAME, KSB_SOCRNAME, KSB_KOD)
		SELECT LEVEL, SCNAME, SOCRNAME, KOD_T_ST
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select LEVEL, SCNAME, SOCRNAME, KOD_T_ST  from SOCRBASE')

		TRUNCATE TABLE Kladr.Street

		INSERT INTO Kladr.Street (KS_NAME, KS_SOCR, KS_CODE, KS_INDEX, KS_GNINMB, KS_UNO, KS_OCATD)
		SELECT NAME, SOCR, CODE, [INDEX], GNINMB, UNO, OCATD
		FROM OPENROWSET('MSDASQL','Driver=Microsoft Visual FoxPro Driver;SourceDB=E:\KLADR\;SourceType=DBF;codepage=OEM','select NAME, SOCR, CODE, INDEX, GNINMB, UNO, OCATD from STREET')

		EXEC Kladr.KLADR_TREE_CREATE
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Kladr].[KLADR_RELOAD] TO rl_kladr_w;
GO
