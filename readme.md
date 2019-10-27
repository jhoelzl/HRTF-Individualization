HRTF Adaptation Tool in Matlab
=========================
This tool consists of a set of matlab functions and GUIs to provide an customization process of HRTFs using three open access HRTF databases.

Individual head-related transfer functions (HRTFs) can be used to generate
virtual sound sources over headphones. According to the model of
HRTF individualization using Principal Components (PCs), a Principal
Component Weight (PCW) set is sought that when multiplied with a PC
basis results in an HRTF set that yields good localization for a number of
given directions of sound incidence. Although this is a promising model,
the extent to which listeners can perform the individualization by hearing
is debatable. The process requires adjustment for each location and PC
of interest. 

<img align="right" src="https://github.com/jhoelzl/HRTF-Individualization/blob/master/images/hrtf_%20adaptation_process.png?raw=true"> In this work, the feasibility of a local and global method is
numerically evaluated by estimating the accuracy with which a given basis
component can model HRTFs regarding different kinds of input data. The
number of required adjustments for a given direction set is then reduced
by decomposing the PCW of individual users upon a Spherical Harmonics
Basis. Optimal spherical model parameters are sought, depending on the
order and reconstruction accuracy. In a listening test, subjects were asked
to identify changes in localization when weights of individual directions
are automatically modified. This allows a deeper inside into the usability
of each technique.

Requirements
--------------
1.  Matlab

2. At least one of these open access HRTF databases:

* [ARI](https://www.kfs.oeaw.ac.at/index.php?option=com_content&view=article&id=608:ari-hrtf-database&catid=158:resources-items&Itemid=606&lang=en) (Acoustics Research Institute) with 85 subjects and 1550 source positions 
* [CIPIC](https://www.ece.ucdavis.edu/cipic/spatial-sound/hrtf-data/) (University of California at Davis) with 45 subjects and 1250 source positions 
* [IRCAM](http://recherche.ircam.fr/equipes/salles/listen/) (Institut de Recherche et Coordination Acoustique/Musique) with 50 subjects and 187 source positions 

Please download these databases and copy the content into the directory [`db/`](https://github.com/jhoelzl/HRTF-Individualization/tree/master/db).

## Getting Started

* Clone or download this repository: `git clone https://github.com/jhoelzl/HRTF-Individualization.git`
* Add at least one of the HRTF databases listed above and extract the contents into `db/database-name/`. Alternatively you can use a custom HRTF database and add the import function in [`model/matlabcode/functions/core/database_import.m`](https://github.com/jhoelzl/HRTF-Individualization/blob/master/model/matlabcode/functions/core/database_import.m).
* Adjust your active HRTF databases in [`model/matlabcode/config.xml`](https://github.com/jhoelzl/HRTF-Individualization/blob/master/model/matlabcode/config.xml)
* In Matlab add `model/matlabcode` to the search path (use `addpath` or go through menu settings)
* Go to Matlab code directory: `cd model/matlabcode`
* Run [`gui_model`](https://github.com/jhoelzl/HRTF-Individualization/blob/master/model/matlabcode/gui/model/gui_model.m) in Matlab. A graphical user interface like in the screenshot below should appear.

## HRTF Model
![HRTF Model GUI](https://raw.githubusercontent.com/jhoelzl/HRTF-Individualization/master/images/hrtf_model_overview.png)


## Graphical User Interface
![HRTF Model GUI](https://github.com/jhoelzl/HRTF-Individualization/blob/master/images/hrtf_model_gui.jpg?raw=true)

## Mathematical Background 

### Principal Component Analaysis (PCA)
Principal Component Analysis is a robust statistical method for data representation. The technique projects an original dataset on an orthogonal subspace that is estimated by taking the covariance of the data into account. The technique can be used to unveil relationships between the independent variables in a dataset and in this way reduce a high-dimensional dataset into a more meaningful, low-dimensional space. It has been widely used in computer vision and pattern recognition to find relevant structure in data and neglect redundant information. Usually the input data is pre-processed and aligned prior PCA to increase the performance. The resulting model parameters can be calculated directly from the input data through Singular Value Decomposition (SVD). Through a linear combination of the new basis and their corresponding principal weights, the original dataset can be reconstructed with a controllable accuracy, because the orthogonal principal components are sorted according to their variance describing the original data.

### Spherical Harmonic Decomposition (SH)
Spherical Harmonic Decomposition, primary intended for the modeling and approximation of continuous functions on the sphere, has also been applied to model HRTFs. As HRTF measurements occur for positions distributed on a sphere, or spherical sections, such an approach is inherently appropriate. The dataset is projected onto spherical basis functions of a desired order, whose weighted combination can be used for modeling or approximation purposes. In contrast to PCA, where the basis functions are computed from the dataset, the spherical harmonic functions are fixed and defined hierarchically.

## Conclusion
#### Diploma Thesis
* Title: [A Global Model for HRTF Individualization by Adjustment of Principal Component Weights](https://github.com/jhoelzl/HRTF-Individualization/blob/master/pdf/Josef%20Hölzl%20-%20A%20Global%20Model%20for%20HRTF%20Individualization%20by%20Adjustment%20of%20Principal%20Component%20Weights.pdf?raw=true) 
* Author: Josef Hölzl
* Date: March 2014
* Host Institution: Institute of Electronic Music and Acoustics, University of Music and Performing Arts Graz, Graz University of Technology

#### Project Thesis
* Title: [An initial Investigation into HRTF Adaptation using PCA](https://github.com/jhoelzl/HRTF-Individualization/blob/master/pdf/Josef%20Hölzl%20-%20An%20initial%20Investigation%20into%20HRTF%20Adaptation%20using%20PCA.pdf?raw=true)
* Author: Josef Hölzl
* Date: July 2012
* Institute of Electronic Music and Acoustics, Graz, Austria

[![Analytics](https://ga-beacon.appspot.com/UA-796927-10/jhoelzl/HRTF-Individualization/readme?pixel)](https://github.com/igrigorik/ga-beacon)

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=jhoelzl&url=https%3A%2F%2Fgithub.com%2Fjhoelzl%2FHRTF-Individualization&title=HRTF-Individualization&language=Matlab&tags=github&category=software)



