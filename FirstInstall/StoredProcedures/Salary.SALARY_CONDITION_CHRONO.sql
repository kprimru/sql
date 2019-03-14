USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Salary].[SALARY_CONDITION_CHRONO]
	@SC_WEIGHT		DECIMAL(8, 4),
	@SC_VALUE		MONEY,
	@SC_ID_PER_TYPE	UNIQUEIDENTIFIER,
	@SC_DATE		SMALLDATETIME,
	@SC_ID_MASTER	UNIQUEIDENTIFIER,
	@SC_END			SMALLDATETIME,
	@SC_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', @SC_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Salary.SalaryConditionDetail
		SET		SC_END	=	@SC_END,
				SC_REF	=	2
		WHERE	SC_ID	=	@SC_ID	

		UPDATE	Salary.SalaryCondition
		SET		SCMS_LAST	=	GETDATE()
		WHERE	SCMS_ID		=	@SC_ID_MASTER

		INSERT INTO 
				Salary.SalaryConditionDetail(
					SC_ID_MASTER,
					SC_WEIGHT,
					SC_VALUE,
					SC_ID_PER_TYPE,
					SC_DATE
				)
		OUTPUT INSERTED.SC_ID INTO @TBL
		VALUES	(
					@SC_ID_MASTER,
					@SC_WEIGHT,
					@SC_VALUE,
					@SC_ID_PER_TYPE,
					@SC_DATE
				)

		SELECT	@SC_ID = ID
		FROM	@TBL		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', @SC_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'SALARY_CONDITION', '��������������� ���������', @SC_ID_MASTER, @OLD, @NEW


END

