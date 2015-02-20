HRFT Adaptation Tool in Matlab
=========================
Individual head-related transfer functions (HRTFs) can be used to generate
virtual sound sources over headphones. According to the model of
HRTF individualization using Principal Components (PCs), a Principal
Component Weight (PCW) set is sought that when multiplied with a PC
basis results in an HRTF set that yields good localization for a number of
given directions of sound incidence. Although this is a promising model,
the extent to which listeners can perform the individualization by hearing
is debatable. The process requires adjustment for each location and PC
of interest. In this work, the feasibility of a local and global method is
numerically evaluated by estimating the accuracy with which a given basis
component can model HRTFs regarding different kinds of input data. The
number of required adjustments for a given direction set is then reduced
by decomposing the PCW of individual users upon a Spherical Harmonics
Basis. Optimal spherical model parameters are sought, depending on the
order and reconstruction accuracy. In a listening test, subjects were asked
to identify changes in localization when weights of individual directions
are automatically modified. This allows a deeper inside into the usability
of each technique.

This tool consists of a set of matlab functions and GUIs to provide an customization process of HRTFs using three open access HRTF databases:

* ARI (Acoustics Research Institute) with 85 subjects and 1550 source positions (https://www.kfs.oeaw.ac.at/index.php?option=com_content&view=article&id=608:ari-hrtf-database&catid=158:resources-items&Itemid=606&lang=en)
* CIPIC (University of California at Davis) with 45 subjects and 1250 source positions (http://interface.cipic.ucdavis.edu/sound/hrtf.html)
* IRCAM (Institut de Recherche et Coordination Acoustique/Musique) with 50 subjects and 187 source positions (http://recherche.ircam.fr/equipes/salles/listen/)

## Customization Process
t.b.d


### Graphical User Interface
t.b.d

## Mathematical Background 

### Principal Component Analaysis (PCA)

### Spherical Harmonics Decomposition (SH)

## Thesis
* Title: A Global Model for HRTF Individualization by Adjustment of Principal Component Weights
* Author: Josef Hölzl
* Date: March 2014
* Host Institution: Institute of Electronic Music and Acoustics, University of Music and Performing Arts Graz, Graz University of Technology


