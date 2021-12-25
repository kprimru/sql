USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Clients].[ClientDetail]
(
        [CL_ID]          UniqueIdentifier      NOT NULL,
        [CL_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [CL_NAME]        VarChar(150)          NOT NULL,
        [CL_DATE]        SmallDateTime         NOT NULL,
        [CL_END]         SmallDateTime             NULL,
        [CL_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED ([CL_ID]),
        CONSTRAINT [FK_Clients_Clients] FOREIGN KEY  ([CL_ID_MASTER]) REFERENCES [Clients].[Clients] ([CLMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_ClientDetail__CL_NAME_CL_REF] ON [Clients].[ClientDetail] ([CL_NAME] ASC, [CL_REF] ASC) INCLUDE ([CL_ID], [CL_ID_MASTER]);
CREATE NONCLUSTERED INDEX [IX_ClientDetail__CL_REF] ON [Clients].[ClientDetail] ([CL_REF] ASC) INCLUDE ([CL_ID_MASTER], [CL_NAME]);
CREATE NONCLUSTERED INDEX [IX_ClientDetail_CL_ID_MASTER_CL_REF] ON [Clients].[ClientDetail] ([CL_ID_MASTER] ASC, [CL_REF] ASC) INCLUDE ([CL_ID], [CL_NAME]);
GO
