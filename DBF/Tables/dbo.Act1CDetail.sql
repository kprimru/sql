USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Act1CDetail]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier      NOT NULL,
        [ID_CLIENT]      Int                   NOT NULL,
        [CL_FULL_NAME]   VarChar(512)          NOT NULL,
        [CL_INN]         VarChar(32)           NOT NULL,
        [CL_PSEDO]       VarChar(50)           NOT NULL,
        [ACT_PRICE]      Money                 NOT NULL,
        [ACT_NDS]        Money                     NULL,
        [ACT_NOTE]       NVarChar(Max)             NULL,
        CONSTRAINT [PK_dbo.Act1CDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.Act1CDetail(ID_MASTER)_dbo.Act1C(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[Act1C] ([ID]),
        CONSTRAINT [FK_dbo.Act1CDetail(ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.Act1CDetail(ID_MASTER)+(ID_CLIENT,CL_PSEDO,ACT_PRICE)] ON [dbo].[Act1CDetail] ([ID_MASTER] ASC) INCLUDE ([ID_CLIENT], [CL_PSEDO], [ACT_PRICE]);
GO
